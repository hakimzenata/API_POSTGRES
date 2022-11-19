package com.api.api_serve;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class Srv {

    @Autowired
    Datasrc data;

    public List<Dept> alldeps(){
        return this.data.findAll();
    }

    public  Dept addDept(Dept d){
        return this.data.save(d);
    }

    public Optional<Dept> getDepById(int id){
        return this.data.findById(id);
    }

    public Optional<Dept> updateDep(int id){
        return this.data.findById(id);
    }

    public void rmDepById(int id){
        this.data.deleteById(id);
    }

    public void rmAllDepts(){
        this.data.deleteAll();
    }

}
