package com.api.api_serve;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface Datasrc extends JpaRepository<Dept, Integer> {
}
