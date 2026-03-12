package com.NND.tech.Structure_Backend.Controller;

import com.NND.tech.Structure_Backend.DTO.*;
import com.NND.tech.Structure_Backend.model.entity.Transaction;
import com.NND.tech.Structure_Backend.model.entity.ServiceEntity;
import com.NND.tech.Structure_Backend.model.entity.Structure;
import com.NND.tech.Structure_Backend.Repository.TransactionRepository;
import com.NND.tech.Structure_Backend.Repository.ServiceRepository;
import com.NND.tech.Structure_Backend.Repository.StructureRepository;
import com.NND.tech.Structure_Backend.Service.CampostPaymentService;
import jakarta.validation.Valid;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;

@RestController
@RequestMapping("/api/paiements")
public class PaymentController {

    private final CampostPaymentService campostService;
    private final TransactionRepository transactionRepository;
    private final StructureRepository structureRepository;
    private final ServiceRepository serviceRepository;

    public PaymentController(CampostPaymentService campostService,
                             TransactionRepository transactionRepository,
                             StructureRepository structureRepository,
                             ServiceRepository serviceRepository) {
        this.campostService = campostService;
        this.transactionRepository = transactionRepository;
        this.structureRepository = structureRepository;
        this.serviceRepository = serviceRepository;
    }

    @GetMapping("/operators")
    public ResponseEntity<List<OperatorDto>> getOperators() {
        return ResponseEntity.ok(campostService.getOperators());
    }

    @GetMapping("/balance")
    public ResponseEntity<BalanceDto> getBalance() {
        return ResponseEntity.ok(campostService.getBalance());
    }

    @GetMapping("/find/{orderId}")
    public ResponseEntity<FindResponse> findByOrder(@PathVariable String orderId) {
        return ResponseEntity.ok(campostService.findByOrderId(orderId));
    }

    @PostMapping(value = "/initier", consumes = MediaType.APPLICATION_JSON_VALUE)
    @Transactional
    public ResponseEntity<InitiatePaymentResponse> initiate(@Valid @RequestBody InitiatePaymentRequest req) {
        String reference = campostService.initReference();

        Structure structure = structureRepository.findById(req.getStructureId())
                .orElseThrow(() -> new IllegalArgumentException("Structure not found"));
        ServiceEntity service = serviceRepository.findById(req.getServiceId())
                .orElseThrow(() -> new IllegalArgumentException("Service not found"));

        String orderId = req.getOrderId();
        if (orderId == null || orderId.isBlank()) {
            orderId = "ORD-" + java.time.format.DateTimeFormatter.ofPattern("yyyyMMddHHmmss").format(java.time.LocalDateTime.now())
                    + "-" + String.format("%04d", new java.util.Random().nextInt(10000));
            req.setOrderId(orderId);
        }

        Transaction t = new Transaction();
        t.setAmount(BigDecimal.valueOf(req.getAmount()));
        t.setTransactionDate(LocalDate.now());
        t.setDescription(req.getReason());
        t.setOrderId(orderId);
        t.setStatus("PENDING");
        t.setService(service);
        t.setStructure(structure);

        // Ask CamPost for payment link using the initial reference, but persist the final reference returned
        InitiatePaymentResponse response = campostService.createPaymentLink(req, reference);
        String finalReference = response.getReference() != null ? response.getReference() : reference;
        t.setReference(finalReference);
        transactionRepository.save(t);

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/verify/{orderId}")
    public ResponseEntity<Map<String, Object>> verify(@PathVariable String orderId,
                                                      @RequestParam(name = "timeoutMs", required = false, defaultValue = "300000") long timeoutMs,
                                                      @RequestParam(name = "intervalMs", required = false, defaultValue = "5000") long intervalMs) {
        String status = campostService.pollAndUpdateStatus(orderId, timeoutMs, intervalMs);
        Map<String, Object> body = new HashMap<>();
        body.put("orderId", orderId);
        body.put("status", status);
        body.put("updatedAt", java.time.OffsetDateTime.now().toString());
        return ResponseEntity.ok(body);
    }

    @PostMapping(value = "/webhooks/campost", consumes = MediaType.APPLICATION_JSON_VALUE)
    @Transactional
    public ResponseEntity<Void> webhook(@RequestBody String payload, @RequestHeader HttpHeaders headers) {
        String signature = headers.getFirst("X-SIGNATURE");
        if (!campostService.verifyWebhook(payload, signature)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        CampostWebhookEvent event = JsonUtils.fromJson(payload, CampostWebhookEvent.class);
        if (event == null || event.getReference() == null) return ResponseEntity.ok().build();
        Optional<Transaction> opt = transactionRepository.findAll().stream()
                .filter(tx -> event.getReference().equals(tx.getReference()))
                .findFirst();
        if (opt.isEmpty()) return ResponseEntity.ok().build();
        Transaction tx = opt.get();
        if ("SUCCESS".equalsIgnoreCase(event.getStatus())) {
            tx.confirm();
        } else if ("FAILED".equalsIgnoreCase(event.getStatus()) || "CANCELLED".equalsIgnoreCase(event.getStatus())) {
            tx.cancel();
        }
        transactionRepository.save(tx);
        return ResponseEntity.ok().build();
    }

    // Simple JSON utils to avoid extra dependencies
    static class JsonUtils {
        static <T> T fromJson(String json, Class<T> clazz) {
            try {
                com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
                return mapper.readValue(json, clazz);
            } catch (Exception e) {
                return null;
            }
        }
    }
}
