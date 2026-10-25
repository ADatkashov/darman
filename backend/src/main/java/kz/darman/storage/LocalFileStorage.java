package kz.darman.storage;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.*;
import java.util.regex.Pattern;
import kz.darman.config.AppProperties;
import org.springframework.stereotype.Component;

/**
 * Development/single-node adapter storing files on local disk outside any web root.
 * Production deployments should provide an S3-compatible private-bucket implementation of {@link FileStorage}.
 */
@Component
public class LocalFileStorage implements FileStorage {
    private static final Pattern SAFE_KEY = Pattern.compile("^[A-Za-z0-9/_.-]{10,200}$");
    private final Path root;

    public LocalFileStorage(AppProperties props) throws IOException {
        this.root = Paths.get(props.storage().privatePath()).toAbsolutePath().normalize();
        Files.createDirectories(root);
    }

    private Path resolve(String key) {
        if (!SAFE_KEY.matcher(key).matches() || key.contains("..")) throw new IllegalArgumentException("Invalid storage key");
        Path p = root.resolve(key).normalize();
        if (!p.startsWith(root)) throw new IllegalArgumentException("Invalid storage key");
        return p;
    }

    @Override
    public void put(String key, InputStream data, long size) throws IOException {
        Path p = resolve(key);
        Files.createDirectories(p.getParent());
        Files.copy(data, p, StandardCopyOption.REPLACE_EXISTING);
    }

    @Override
    public InputStream open(String key) throws IOException {
        return Files.newInputStream(resolve(key));
    }

    @Override
    public void delete(String key) throws IOException {
        Files.deleteIfExists(resolve(key));
    }
}
