package com.example;

import org.springframework.web.bind.annotation.*;

import java.util.concurrent.atomic.AtomicInteger;

@RestController
@RequestMapping("/echo")
public class EchoController {

    private AtomicInteger counter = new AtomicInteger();

    @GetMapping("/{id}")
    public String echo(@PathVariable("id") String id) {
        return id + ":" + counter.incrementAndGet();
    }

}
