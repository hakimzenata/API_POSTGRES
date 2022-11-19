package com.api.api_serve;

import javax.persistence.*;

@Entity
@Table(name="dept")
public class Dept {

    @Id
    @Column(name = "deptno", nullable = false)
    private int id;

    @Column(name = "dname", length = 14, nullable = false)
    private String dname;

    @Column(name = "loc", length = 13, nullable = false)
    private String loc;

    public Dept(){

    }

    public Dept(int id, String dname, String loc) {
        this.id = id;
        this.dname=dname;
        this.loc = loc;
    }

    public String getName(){
        return dname;
    }

    public String getLoc(){
        return loc;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public void setName(String dname){
        this.dname = dname;
    }

    public void setLoc(String loc){
        this.loc = loc;
    }

}
