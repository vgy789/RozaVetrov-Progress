using RozaVetrov_TarifEditor.Domain;
using System;
using System.Collections.Generic;
using System.Text;

namespace RozaVetrov_TarifEditor.DataFiles
{
    public static class ConnectionString
    {
        private static string _encryptedSecret = DataProtection.EncodeDecrypt("" +
                "Host=localhost;Port=5434;" +
                "Database=roza_vetrov;" +
                "Username=postgres;" +
                "Password=postgres");

        public static string EncryptedSecret { get; } = _encryptedSecret;
    }
}