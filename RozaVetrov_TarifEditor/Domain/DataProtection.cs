using System;
using System.Linq;

namespace RozaVetrov_TarifEditor.Domain
{
    static class DataProtection
    {
        static ushort secretKey;

        static DataProtection()
        {
            Random random = new Random();
            ushort value = (ushort)random.Next(0, 65536);
            secretKey = value; // Секретный ключ (длина - 16 bit).
        }

        /// <summary>
        /// Шифрование/Расшифровывание строки.
        /// </summary>
        /// <param name="data">Шифруемая/Расшифровываемая строка.</param>
        /// <returns></returns>
        public static string EncodeDecrypt(string str)
        {
            var ch = str.ToArray();
            string newStr = "";
            foreach (var c in ch)
                newStr += TopSecret(c);
            return newStr;
        }

        private static char TopSecret(char character)
        {
            character = (char)(character ^ secretKey); //Производим XOR операцию
            return character;
        }
    }
}
