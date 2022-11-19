package com.api.api_serve;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api")
public class Controler {

    @Autowired
    Srv service;

    @RequestMapping(value = "/all", method = RequestMethod.GET)
    public List<Dept> alldeps(){
        return this.service.alldeps();
    }

    // http://localhost:8080/dept/1
    @RequestMapping(
            value = "/{id}",
            method = RequestMethod.GET
    )
    public Optional<Dept> getDep(@PathVariable int id){
        System.out.println(this.service.getDepById(id));
        return this.service.getDepById(id);
    }

    @RequestMapping(value = "/addd", method = RequestMethod.POST,
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public Dept addDep(@RequestBody Dept d) {
        return this.service.addDept(d);
    }

    @RequestMapping(value = "/update/{id}", method = RequestMethod.PUT,
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public Optional<Dept> updatedep(@PathVariable int id) {
        return this.service.updateDep(id);
    }

    @RequestMapping(value = "/rm/all",
            method = RequestMethod.DELETE)
    public void rmAllDepts () {
        this.service.rmAllDepts();
    }

    @RequestMapping(value = "/rm/{id}",
            method = RequestMethod.DELETE)
    public void rmDepByIs(@PathVariable int id) {
        this.service.rmDepById(id);
    }

}
