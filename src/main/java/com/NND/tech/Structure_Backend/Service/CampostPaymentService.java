package com.NND.tech.Structure_Backend.Service;

import com.NND.tech.Structure_Backend.DTO.*;
import com.NND.tech.Structure_Backend.Repository.TransactionRepository;
import com.NND.tech.Structure_Backend.config.CampostProperties;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.*;

@Service
public class CampostPaymentService {
    private final RestTemplate restTemplate;
    private final CampostProperties props;
    private final TransactionRepository transactionRepository;

    public CampostPaymentService(RestTemplate restTemplate, CampostProperties props, TransactionRepository transactionRepository) {
        this.restTemplate = restTemplate;
        this.props = props;
        this.transactionRepository = transactionRepository;
    }

    private HttpHeaders defaultHeaders(boolean withPrivateKey) {
        HttpHeaders headers = new HttpHeaders();
        headers.setAccept(Collections.singletonList(MediaType.APPLICATION_JSON));
        headers.set("X-PUBLIC-KEY", props.getPublicKey());
        headers.set("User-Agent", "Structure-Backend/1.0 (Spring RestTemplate)");
        headers.set("Connection", "close");
        if (withPrivateKey) {
            headers.set("X-PRIVATE-KEY", props.getPrivateKey());
        }
        return headers;
    }

    public String initReference() {
        String url = props.getApiBaseUrl() + "/transaction/init";
        HttpEntity<Void> entity = new HttpEntity<>(defaultHeaders(false));
        ResponseEntity<Map> response = exchangeWithRetry(url, HttpMethod.GET, entity, Map.class);
        Object ref = response.getBody() != null ? response.getBody().get("reference") : null;
        if (ref == null) throw new RestClientException("Missing reference from CamPost");
        return ref.toString();
    }

    public InitiatePaymentResponse createPaymentLink(InitiatePaymentRequest req, String reference) {
        String url = props.getApiBaseUrl() + "/paymentLink";
        HttpHeaders headers = defaultHeaders(false);
        headers.setContentType(MediaType.APPLICATION_JSON);
        Map<String, Object> body = new HashMap<>();
        body.put("amount", req.getAmount());
        body.put("currency", req.getCurrency());
        body.put("reason", req.getReason());
        body.put("orderId", req.getOrderId());
        Map<String, Object> customer = new HashMap<>();
        customer.put("firstName", req.getCustomer().getFirstName());
        customer.put("lastName", req.getCustomer().getLastName());
        customer.put("phoneNumber", req.getCustomer().getPhoneNumber());
        customer.put("email", req.getCustomer().getEmail());
        customer.put("language", req.getCustomer().getLanguage());
        body.put("customer", customer);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);
        ResponseEntity<Map> response = postWithRetry(url, entity, Map.class);
        Map res = response.getBody();
        if (res == null) throw new RestClientException("Empty response from CamPost /paymentLink");
        String paymentLink = Objects.toString(res.get("paymentLink"), null);
        String ref = Objects.toString(res.get("reference"), reference);
        return new InitiatePaymentResponse(ref, paymentLink, req.getOrderId());
    }

    public List<OperatorDto> getOperators() {
        String url = props.getApiBaseUrl() + "/operator/list";
        HttpEntity<Void> entity = new HttpEntity<>(defaultHeaders(false));
        ResponseEntity<Map> response = exchangeWithRetry(url, HttpMethod.GET, entity, Map.class);
        Map body = response.getBody();
        if (body == null) return Collections.emptyList();
        List<Map<String, Object>> ops = (List<Map<String, Object>>) body.get("operators");
        if (ops == null) return Collections.emptyList();
        List<OperatorDto> result = new ArrayList<>();
        for (Map<String, Object> m : ops) {
            OperatorDto dto = new OperatorDto();
            dto.setName(Objects.toString(m.get("name"), null));
            dto.setSlug(Objects.toString(m.get("slug"), null));
            dto.setIcon(Objects.toString(m.get("icon"), null));
            dto.setImage(Objects.toString(m.get("image"), null));
            result.add(dto);
        }
        return result;
    }

    public BalanceDto getBalance() {
        String url = props.getApiBaseUrl() + "/balance";
        HttpEntity<Void> entity = new HttpEntity<>(defaultHeaders(true));
        ResponseEntity<BalanceDto> response = exchangeWithRetry(url, HttpMethod.GET, entity, BalanceDto.class);
        return response.getBody();
    }

    public FindResponse findByOrderId(String orderId) {
        String url = props.getApiBaseUrl() + "/find/" + orderId;
        HttpEntity<Void> entity = new HttpEntity<>(defaultHeaders(false));
        ResponseEntity<FindResponse> response = exchangeWithRetry(url, HttpMethod.GET, entity, FindResponse.class);
        return response.getBody();
    }

    public Map<String, Object> getStatusByReference(String reference) {
        String url = props.getApiBaseUrl() + "/status/" + reference;
        HttpEntity<Void> entity = new HttpEntity<>(defaultHeaders(false));
        ResponseEntity<Map> response = exchangeWithRetry(url, HttpMethod.GET, entity, Map.class);
        return response.getBody();
    }

    public boolean verifyWebhook(String payload, String signature) {
        if (signature == null) return false;
        String expected = hmacSha256Hex(props.getWebhookSecret(), payload);
        return constantTimeEquals(expected, signature);
    }

    private <T> ResponseEntity<T> exchangeWithRetry(String url, HttpMethod method, HttpEntity<?> entity, Class<T> responseType) {
        RestClientException last = null;
        for (int i = 0; i < 2; i++) {
            try {
                return restTemplate.exchange(url, method, entity, responseType);
            } catch (RestClientException ex) {
                last = ex;
                sleepQuiet(500L);
            }
        }
        throw last != null ? last : new RestClientException("HTTP call failed: " + url);
    }

    private <T> ResponseEntity<T> postWithRetry(String url, HttpEntity<?> entity, Class<T> responseType) {
        RestClientException last = null;
        for (int i = 0; i < 2; i++) {
            try {
                return restTemplate.postForEntity(url, entity, responseType);
            } catch (RestClientException ex) {
                last = ex;
                sleepQuiet(500L);
            }
        }
        throw last != null ? last : new RestClientException("HTTP POST failed: " + url);
    }

    private static void sleepQuiet(long ms) {
        try { Thread.sleep(ms); } catch (InterruptedException ignored) { Thread.currentThread().interrupt(); }
    }

    private static String hmacSha256Hex(String secret, String data) {
        try {
            Mac sha256_HMAC = Mac.getInstance("HmacSHA256");
            SecretKeySpec secret_key = new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
            sha256_HMAC.init(secret_key);
            byte[] raw = sha256_HMAC.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(raw.length * 2);
            for (byte b : raw) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new IllegalStateException("Cannot compute HMAC-SHA256", e);
        }
    }

    private static boolean constantTimeEquals(String a, String b) {
        if (a == null || b == null) return false;
        if (a.length() != b.length()) return false;
        int result = 0;
        for (int i = 0; i < a.length(); i++) {
            result |= a.charAt(i) ^ b.charAt(i);
        }
        return result == 0;
    }

    /**
     * Poll CamPost for a given orderId until a terminal state or timeout, then update the local transaction.
     * @param orderId merchant order identifier
     * @param maxWaitMs maximum time to wait (default 300_000 ms)
     * @param intervalMs polling interval (default 5_000 ms)
     * @return final status: SUCCESS, FAILED, CANCELLED, INSUFFICIENT_FUNDS, or TIMEOUT
     */
    public String pollAndUpdateStatus(String orderId, long maxWaitMs, long intervalMs) {
        long deadline = System.currentTimeMillis() + Math.max(1_000L, maxWaitMs);
        long interval = Math.max(1_000L, intervalMs);
        String finalStatus = "TIMEOUT";

        // Try to use provider reference if we already have it locally
        Optional<com.NND.tech.Structure_Backend.model.entity.Transaction> localTxOpt = transactionRepository.findFirstByOrderId(orderId);
        String providerRef = localTxOpt.map(com.NND.tech.Structure_Backend.model.entity.Transaction::getReference).orElse(null);

        while (System.currentTimeMillis() < deadline) {
            try {
                String status = null;
                if (providerRef != null && !providerRef.isBlank()) {
                    Map<String, Object> map = getStatusByReference(providerRef);
                    if (map != null) {
                        Object st = map.get("status");
                        if (st != null) status = st.toString();
                    }
                } else {
                    FindResponse fr = findByOrderId(orderId);
                    if (fr != null && fr.getTransactions() != null && !fr.getTransactions().isEmpty()) {
                        status = fr.getTransactions().get(0).getStatus();
                    }
                }
                if (status != null) {
                    String s = status.toUpperCase(Locale.ROOT);
                    // Option A: loop only while status == CREATED, stop when != CREATED
                    if (!s.equals("CREATED")) {
                        finalStatus = s; // persist exactly provider status
                        break;
                    }
                }
            } catch (RestClientException ignored) {
                // transient failure, continue polling
            }
            sleepQuiet(interval);
        }

        final String statusToPersist = finalStatus;
        transactionRepository.findFirstByOrderId(orderId).ifPresent(tx -> {
            if ("SUCCESS".equals(statusToPersist)) {
                tx.confirm(); // sets status=SUCCESS, isConfirmed=true, date
            } else if ("TIMEOUT".equals(statusToPersist)) {
                tx.setConfirmed(false);
                tx.setStatus("TIMEOUT");
                tx.setConfirmationDate(null);
            } else if (statusToPersist != null) {
                // For CREATED/FAILED/CANCELLED/INSUFFICIENT_FUNDS or any other provider status
                tx.setConfirmed(false);
                tx.setStatus(statusToPersist);
                tx.setConfirmationDate(null);
            }
            transactionRepository.save(tx);
        });
        return finalStatus;
    }
}
