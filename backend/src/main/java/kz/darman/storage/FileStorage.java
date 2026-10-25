package kz.darman.storage;

import java.io.IOException;
import java.io.InputStream;

/** Private object storage for sensitive documents. Implementations must never expose public URLs. */
public interface FileStorage {
    void put(String key, InputStream data, long size) throws IOException;

    InputStream open(String key) throws IOException;

    void delete(String key) throws IOException;
}
