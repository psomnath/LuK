using Microsoft.WindowsAzure.Storage.Auth;
using Microsoft.WindowsAzure.Storage.Blob;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace Luk.Utilities
{
    public static class AzureBlobHelper
    {
        public static void UploadImageToBlob(byte[] imageToWrite, string imageName)
        {
            // https://lukfunctionapp2021101318.blob.core.windows.net/matched-images/IMG-0489.jpg

            var credentials = new StorageCredentials("lukfunctionapp2021101318", "yAMLJXmKQTh6txAT0pSI1Lp8tnZHhDJqhPet8bL4102GfsfGADwj/c3v0OB09kZh3t3EkKldIZJ+ZmwM3y+UQQ==");
            var client = new CloudBlobClient(new Uri("https://lukfunctionapp2021101318.blob.core.windows.net/"), credentials);
            var container = client.GetContainerReference("matched-images");
            container.CreateIfNotExistsAsync().GetAwaiter().GetResult();
            var perm = new BlobContainerPermissions();
            perm.PublicAccess = BlobContainerPublicAccessType.Blob;

            var blockBlob = container.GetBlockBlobReference(imageName);
            blockBlob.UploadFromByteArrayAsync(imageToWrite,0, imageToWrite.Length);
        }
    }
}
