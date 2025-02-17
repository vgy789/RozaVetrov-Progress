using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows.Input;

namespace RozaVetrov_TarifEditor.Domain
{
    static class Utility
    {
        /// <summary>
        /// Допускает ввод только русских букв.
        /// </summary>
        /// <param name="e"></param>
        public static void СheckingString(TextCompositionEventArgs e)
        {
            e.Handled = IsTextString(e.Text);
        }

        /// <summary>
        /// Допускает ввод только арабских цифр.
        /// </summary>
        /// <param name="e"></param>
        public static void СheckingNaturalNumeric(TextCompositionEventArgs e)
        {
            e.Handled = IsTextNaturalNumeric(e.Text);
        }

        /// <summary>
        /// Допускает ввод только арабских цифр, точки и запятой.
        /// </summary>
        /// <param name="e"></param>
        public static void СheckingFloatingNumeric(TextCompositionEventArgs e)
        {
            e.Handled = IsTextFloatingNumeric(e.Text);
        }



        /// <summary>
        /// false - присутсвуют русские буквы, true - отсутствуют.
        /// </summary>
        /// <param name="str">Проверяемый символ.</param>
        /// <returns></returns>
        private static bool IsTextString(string str)
        {
            Regex reg = new Regex("[^а-яёА-ЯЁ/-]");
            if (reg.IsMatch(str) == true)
                System.Media.SystemSounds.Asterisk.Play();
            return reg.IsMatch(str);
        }

        /// <summary>
        /// false - присутсвуют арабские цифры, true - отсутствуют.
        /// </summary>
        /// <param name="str">Проверяемый символ.</param>
        /// <returns></returns>
        private static bool IsTextNaturalNumeric(string str)
        {
            Regex reg = new Regex("[^0-9]");
            if(reg.IsMatch(str) == true)
                System.Media.SystemSounds.Asterisk.Play();
            return reg.IsMatch(str);
        }

        /// <summary>
        /// false - присутсвуют арабские цифры, точка или запятая, true - отсутствуют.
        /// </summary>
        /// <param name="str">Проверяемый символ.</param>
        /// <returns></returns>
        private static bool IsTextFloatingNumeric(string str)
        {
            Regex reg = new Regex(@"[^0-9,\.]");
            if (reg.IsMatch(str) == true)
                System.Media.SystemSounds.Asterisk.Play();
            return reg.IsMatch(str);
        }
    }
}
