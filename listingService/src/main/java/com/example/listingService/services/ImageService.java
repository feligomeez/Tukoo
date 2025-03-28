package com.example.listingService.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import com.example.listingService.models.ListingImage;
import com.example.listingService.repository.ListingImageRepository;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;

@Service
public class ImageService {
    private final String uploadDir = "uploads/images/";

    @Autowired
    private ListingImageRepository listingImageRepository;

    public ImageService() {
        createUploadDirectory();
    }

    private void createUploadDirectory() {
        try {
            Files.createDirectories(Paths.get(uploadDir));
        } catch (IOException e) {
            throw new RuntimeException("Could not create upload directory!", e);
        }
    }

    public String saveImage(MultipartFile file) throws IOException {
        String filename = UUID.randomUUID().toString() + "_" + file.getOriginalFilename();
        Path filePath = Paths.get(uploadDir + filename);
        Files.write(filePath, file.getBytes());
        return filename;
    }

    public ListingImage saveImageEntity(ListingImage image) {
        return listingImageRepository.save(image);
    }

    public List<String> getListingImages(Long listingId) {
        return listingImageRepository.findByListingId(listingId)
            .stream()
            .map(ListingImage::getImageUrl)
            .toList();
    }
}