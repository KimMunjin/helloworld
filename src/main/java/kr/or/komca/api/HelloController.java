package kr.or.komca.api;

import kr.or.komca.dto.HelloResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.time.LocalDateTime;


@Slf4j
@RestController
@RequestMapping("/public/api")
@RequiredArgsConstructor
public class HelloController {

    @GetMapping("/hello")
    public ResponseEntity<HelloResponse> hello() {
        log.debug("-------------------- hello" + LocalDateTime.now());
        System.out.println("----------------- hello!!" + LocalDateTime.now());
        HelloResponse response = new HelloResponse(
                "안녕하세요! Spring Boot API 입니다../",
                LocalDateTime.now()
        );

        return ResponseEntity.ok(response);
    }
}