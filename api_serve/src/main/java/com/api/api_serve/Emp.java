package com.api.api_serve;

import javax.persistence.*;

@Entity
@Table(name = "EMP")
public class Emp {

    // variables
    @Id
    @Column(name = "deptno", nullable = false)
    @GeneratedValue(strategy = GenerationType.AUTO)
    private int id;

    @Column(name = "dname")
    private String dname;

    @Column(name = "loc")
    private  String loc;


    // methodes
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

     public String getDeptName(){
        return this.dname;
    }
    public void setDeptName(String s) {
        this.dname = s;
    }
    public String getDeptLoc(){
        return this.loc;
    }
    public void setDeptLoc(String s) {
        this.loc = s;
    }

}