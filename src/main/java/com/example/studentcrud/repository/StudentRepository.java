package com.example.studentcrud.repository;

import com.example.studentcrud.Model.Student;

import org.springframework.data.jpa.repository.JpaRepository;

public interface StudentRepository extends JpaRepository<Student, Long> {
}
