package com.test.demo2.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Controller
public class hellocontroller {
    @RequestMapping("/index")
    public String Hello(){
        return "hello";
    }
    @RequestMapping("/hello")
    public String Success(){
        return "success";
    }
}
