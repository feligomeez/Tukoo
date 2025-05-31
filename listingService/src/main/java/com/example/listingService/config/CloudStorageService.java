package com.example.listingService.config;

import com.google.auth.oauth2.ServiceAccountCredentials;
import com.google.cloud.storage.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.UUID;

@Service
public class CloudStorageService {

    private final Storage storage;
    private final String bucketName;

    public CloudStorageService(@Value("${gcp.bucket.name}") String bucketName,
                             @Value("${gcp.credentials.path}") String credentialsPath) throws IOException {
        this.bucketName = bucketName;

        ClassPathResource resource = new ClassPathResource(credentialsPath);
        this.storage = StorageOptions.newBuilder()
                .setCredentials(ServiceAccountCredentials.fromStream(resource.getInputStream()))
                .build()
                .getService();
    }

    public String uploadFile(MultipartFile file) throws IOException {
        String fileName = UUID.randomUUID() + "-" + file.getOriginalFilename();
        BlobId blobId = BlobId.of(bucketName, fileName);
        BlobInfo blobInfo = BlobInfo.newBuilder(blobId).setContentType(file.getContentType()).build();

        storage.create(blobInfo, file.getBytes());

        // Retornar URL pública (si el bucket tiene acceso público)
        return String.format("https://storage.googleapis.com/%s/%s", bucketName, fileName);
    }
}