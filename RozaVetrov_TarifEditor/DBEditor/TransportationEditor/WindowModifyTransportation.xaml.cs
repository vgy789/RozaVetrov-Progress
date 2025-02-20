using RozaVetrov_TarifEditor.DataFiles;
using RozaVetrov_TarifEditor.DataFiles.Models;
using RozaVetrov_TarifEditor.Domain;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using Size = RozaVetrov_TarifEditor.DataFiles.Models.Size;
using System.Threading;

namespace RozaVetrov_TarifEditor.DBEditor.TransportationEditor
{
    /// <summary>
    /// Страница для просмотра и редактирования таблиц БД - Transportation, MinimalWeightPrice, WeightCoefficient, SizeCoefficient.
    /// </summary>
    public partial class WindowModifyTransportation : Window
    {
        /// <summary>
        /// Возможные режимы окна
        /// </summary>
        private enum Mode
        {
            CreateTransportation,
            EditTransportation
        }

        /// <summary>
        /// Изменяет свойства InfoLabel
        /// </summary>
        /// <param name="text">Текст</param>
        /// <param name="color">Цвет текста/param>
        private void ChangeInfoLabel(string text, Brush color)
        {
            InfoLabel.Text = "";
            InfoLabel.Foreground = color;
            InfoLabel.Text = text;
        }

        /// <summary>
        /// Текущий режим открытого окна.
        /// </summary>
        private readonly Mode ActiveMode = new Mode();

        private Transportation _selectedTransportation = null;

        public WindowModifyTransportation(Transportation selectedTransportation = null)
        {
            InitializeComponent();

            if (selectedTransportation == null)
            {
                ActiveMode = Mode.CreateTransportation;
            }
            else
            {
                ActiveMode = Mode.EditTransportation;
                _selectedTransportation = selectedTransportation;
            }

            CustomizeInitialViewWindow();
        }

        private void ModifyTransportationButton_Click(object sender, RoutedEventArgs e)
        {
            NextStepTransportation();
            //TODO: Проверь
            DataFiles.PageData.Transportation.RefreshAllElement();
        }

        private void Window_KeyUp(object sender, KeyEventArgs e)
        {
            if (IsKeyEnter(e))
            {
                NextStepTransportation();
            }
            return;
        }
        //
        private void FromComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (InComboBox.SelectedItem == null)
                return;
            FindTransportationAndAddTextBoxsText();
        }
        //
        private void InComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (FromComboBox.SelectedItem == null)
                return;
            FindTransportationAndAddTextBoxsText();
        }

        private void InComboBox_PreviewTextInput(object sender, TextCompositionEventArgs e)
        {
            Utility.СheckingString(e);
        }

        private void FromComboBox_PreviewTextInput(object sender, TextCompositionEventArgs e)
        {
            Utility.СheckingString(e);
        }

        private void PreviewSizeTextInput(object sender, TextCompositionEventArgs e)
        {
            Utility.СheckingNaturalNumeric(e);
        }
       
        private void PreviewWeightTextInput(object sender, TextCompositionEventArgs e)
        {
            Utility.СheckingFloatingNumeric(e);
        }


        /// <summary>
        /// Стартовая настройка свойств отображаемых элементов.
        /// </summary>
        private void CustomizeInitialViewWindow()
        {
            SettingWeightTextBoxs();
            SettingSizeTextBoxs();

            if (ActiveMode == Mode.CreateTransportation)
            {
                SettingCityComboBoxs();
                Title = "Добавить новую перевозку";
                ModifyTransportationButton.Content = "Добавить";
            }
            if (ActiveMode == Mode.EditTransportation)
            {
                FromComboBox.IsEnabled = false;
                InComboBox.IsEnabled = false;

                Title = String.Format(@"Изменить перевозку: {0} - {1}", 
                    _selectedTransportation.Fromcity.Name,
                    _selectedTransportation.Incity.Name);

                SettingCityComboBoxs();
                ModifyTransportationButton.Content = "Изменить";

                FindTransportationAndAddTextBoxsText();
            }

            FromComboBox.Focus();
            return;

            void SettingCityComboBoxs()
            {
                FromComboBox.SelectedValuePath = "City_id";
                FromComboBox.DisplayMemberPath = "Name";
                FromComboBox.ItemsSource = OdbConnectHelper.dbObj.City.OrderBy(x => x.Name).ToList();

                InComboBox.SelectedValuePath = "City_id";
                InComboBox.DisplayMemberPath = "Name";
                InComboBox.ItemsSource = OdbConnectHelper.dbObj.City.OrderBy(x => x.Name).ToList();

                if (ActiveMode == Mode.EditTransportation)
                {
                    FromComboBox.SelectedItem = _selectedTransportation.Fromcity;
                    InComboBox.SelectedItem = _selectedTransportation.Incity;
                }
            }

            void SettingWeightTextBoxs()
            {
                List<Weight> weightDBList = OdbConnectHelper.dbObj.Weight.OrderBy(x => x.WeightId).ToList();
                foreach (var item in weightDBList)
                {
                    TextBox newTB = GetTextBox(item.Name, false, 4);
                    WeightTextBoxs.Children.Add(newTB);
                }
            }

            void SettingSizeTextBoxs()
            {   
                List<Size> sizeDBList = OdbConnectHelper.dbObj.Size.OrderBy(x => x.SizeId).ToList();
                foreach (var item in sizeDBList)
                {
                    TextBox newTB = GetTextBox(item.Name, true, 5);
                    SizeTextBoxs.Children.Add(newTB);
                }
            };


            TextBox GetTextBox(string hint, bool NumberOnly, byte length)
            {
                TextBox textBox = new TextBox
                {
                    VerticalAlignment = VerticalAlignment.Bottom,
                    Margin = new Thickness(8, 0, 0, 0),
                    MaxLength = length,
                    Width = 65,
                    Style = Application.Current.FindResource("MaterialDesignFloatingHintTextBox") as Style
                };
                MaterialDesignThemes.Wpf.HintAssist.SetHint(textBox, hint);

                if (NumberOnly)
                    textBox.PreviewTextInput += PreviewSizeTextInput;
                else
                    textBox.PreviewTextInput += PreviewWeightTextInput;

                return textBox;
            }
        }

        /// <summary>
        /// Проверка на нажетие клавиши "Enter".
        /// </summary>
        /// <param name="e"></param>
        /// <returns></returns>
        private static bool IsKeyEnter(KeyEventArgs e)
        {
            return (e.Key == Key.Enter);
        }

        /// <summary>
        /// Добавить новое значение в таблицу базы данных.
        /// </summary>
        private void NextStepTransportation()
        {
            var findValue = OdbConnectHelper.dbObj.Transportation.FirstOrDefault(
                x =>
                x.Incity == InComboBox.SelectedItem as City
                && x.Fromcity == FromComboBox.SelectedItem as City
                );

            if (ActiveMode == Mode.CreateTransportation)
            {
                if (findValue != null)
                {
                    MessageBox.Show("Такое направление уже есть в базе данных.", "Внимание.");
                    return;
                }
            }
            
            Transportation transportation = new Transportation()
            {
                Fromcity = FromComboBox.SelectedItem as City,
                Incity = InComboBox.SelectedItem as City
            };
            if (TestInputTransportation(transportation) == false)
                return;

            MinimalWeightPrice MinimalWeightPrice = GetMinimalWeightPriceInTextBox(transportation);
            if (TestInputMinimalWeightPrice(MinimalWeightPrice) == false)
                return;
                
            List<WeightCoefficient> WeightCoefficients = GetWeightCoefficientsInTextBox(transportation);
            if (TestInputWeightCoefficients(WeightCoefficients) == false)
                return;

            List<SizeCoefficient> SizeCoefficients = GetSizeCoefficientsInTextBoxs(transportation);
            if (TestInputSizeCoefficients(SizeCoefficients) == false)
                return;
            

            if (ActiveMode == Mode.CreateTransportation)
            {
                AddTransportation(transportation, MinimalWeightPrice, WeightCoefficients, SizeCoefficients);
            }
            if (ActiveMode == Mode.EditTransportation)
            {
                EditTransportation(transportation, MinimalWeightPrice, WeightCoefficients, SizeCoefficients);
            }

            return;



            void AddTransportation(Transportation transportation, MinimalWeightPrice MinimalWeightPrice, List<WeightCoefficient> WeightCoefficients, List<SizeCoefficient> SizeCoefficients)
            {
                OdbConnectHelper.dbObj.Transportation.Add(transportation);
                OdbConnectHelper.dbObj.MinimalWeightPrice.Add(MinimalWeightPrice);
                OdbConnectHelper.dbObj.WeightCoefficient.AddRange(WeightCoefficients);
                OdbConnectHelper.dbObj.SizeCoefficient.AddRange(SizeCoefficients);
                
                ChangeInfoLabel("Добавлено ✓.", Brushes.Green);

                DataFiles.PageData.Transportation.SaveChanges();
                return;
            }

            void EditTransportation(Transportation transportation, MinimalWeightPrice MinimalWeightPrice, List<WeightCoefficient> WeightCoefficients, List<SizeCoefficient> SizeCoefficients)
            {
                _selectedTransportation.Fromcity = transportation.Fromcity;
                _selectedTransportation.Incity = transportation.Incity;

                OdbConnectHelper.dbObj.Transportation.FirstOrDefault(x => x.TransportationId == _selectedTransportation.TransportationId).Fromcity = transportation.Fromcity;
                OdbConnectHelper.dbObj.Transportation.FirstOrDefault(x => x.TransportationId == _selectedTransportation.TransportationId).Incity = transportation.Incity;
                OdbConnectHelper.dbObj.MinimalWeightPrice.FirstOrDefault(x => x.Transportation == _selectedTransportation).Price = MinimalWeightPrice.Price;
                var weightValues = OdbConnectHelper.dbObj.WeightCoefficient.Where(x => x.Transportation == _selectedTransportation).OrderBy(x => x.WeightId).ToList();

                short i = 0;
                foreach (var item in WeightCoefficients)
                {
                    weightValues[i].Price = Convert.ToInt32(item.Price);
                    i += 1;
                }

                var sizeValues = OdbConnectHelper.dbObj.SizeCoefficient.Where(x => x.Transportation == _selectedTransportation).OrderBy(x => x.SizeId).ToList();
                short j = 0;
                foreach (var item in SizeCoefficients)
                {
                    sizeValues[j].Price = Convert.ToInt32(item.Price);
                    j += 1;
                }

                DataFiles.PageData.Transportation.SaveChanges();

                ChangeInfoLabel("Изменено ✓.", Brushes.Green);

                return;
            }

            bool TestInputTransportation(Transportation transportation)
            {
                bool flag = true;
                if (transportation.Fromcity == transportation.Incity)
                {
                    ChangeInfoLabel("Вы указали один и тот же город город для перевозки. Пожалуйста, проверьте город отправки и город прибытия. Они должны быть различны.", Brushes.Red);

                    flag = false;
                }

                if (transportation.Incity == null || transportation.Fromcity == null)
                {
                    ChangeInfoLabel("Вы не указали Город для перевозки. Пожалуйста, проверьте город отправки и город прибытия.", Brushes.Red);

                    flag = false;
                }
                return flag;
            }

            bool TestInputMinimalWeightPrice(MinimalWeightPrice MinimalWeightPrice)
            {
                bool flag = true;
                if (MinimalWeightPrice == null)
                {
                    ChangeInfoLabel("Вы не указали Минимальную стоимость за вес. Пожалуйста, проверьте поле для ввода минимальной стоимости.", Brushes.Red);
                    flag = false;
                }
                return flag;
            }

            bool TestInputWeightCoefficients(List<WeightCoefficient> WeightCoefficients)
            {
                bool flag = true;
                if (WeightCoefficients == null)
                {
                    ChangeInfoLabel("Не все поля стоимости по Весу заполнены. Пожалуйста, проверьте все поля для ввода стоимости по Весу.", Brushes.Red);
                    flag = false;
                }
                return flag;
            }

            bool TestInputSizeCoefficients(List<SizeCoefficient> SizeCoefficients)
            {
                bool flag = true;
                if (SizeCoefficients == null)
                {
                    ChangeInfoLabel("Не все поля стоимости пл Объёму заполнены.Пожалуйста, проверьте все поля для ввода стоимости по Объёму.", Brushes.Red);
                    flag = false;
                }
                return flag;
            }

            MinimalWeightPrice GetMinimalWeightPriceInTextBox(Transportation transportation)
            {
                if (MinimalWeightPriceTextBox.Text == "")
                    return null;

                MinimalWeightPrice MinimalWeightPrice = new MinimalWeightPrice
                {
                    Transportation = transportation,
                    Price = Convert.ToInt16(MinimalWeightPriceTextBox.Text)
                };

                return MinimalWeightPrice;
            }
            
            List<WeightCoefficient> GetWeightCoefficientsInTextBox(Transportation transportation)
            {
                var allWeightTextBox = WeightTextBoxs.Children;
                List<WeightCoefficient> WeightCoefficients = new List<WeightCoefficient>();

                short j = 1;
                foreach (var item in allWeightTextBox)
                {
                    TextBox textBox = (item as TextBox);
                    if (textBox.Text == "")
                    {
                        return null;
                    }

                    WeightCoefficients.Add(
                        new WeightCoefficient
                        {
                            Price = Convert.ToDecimal(textBox.Text.Replace(".", ",")),
                            WeightId = j,
                            Transportation = transportation
                        }
                    );

                    j += 1;
                }
                return WeightCoefficients;
            }

            List<SizeCoefficient> GetSizeCoefficientsInTextBoxs(Transportation transportation)
            {
                var allSizeTextBox = SizeTextBoxs.Children;
                List<SizeCoefficient> SizeCoefficients = new List<SizeCoefficient>();

                short i = 1;
                foreach (var item in allSizeTextBox)
                {
                    TextBox textBox = (item as TextBox);
                    if (textBox.Text == "")
                    {
                        return null;
                    }

                    SizeCoefficients.Add(
                        new SizeCoefficient
                        {
                            Price = Convert.ToInt32(textBox.Text),
                            SizeId = i,
                            Transportation = transportation
                        }
                    );
                    i += 1;
                }
                return SizeCoefficients;
            }
        }

        private void FindTransportationAndAddTextBoxsText()
        {
            if (ActiveMode == Mode.CreateTransportation)
            {
                ClearTextBoxs();
            }
            
            if (FromComboBox.SelectedItem as City == InComboBox.SelectedItem as City)
            {
                InfoLabel.Foreground = Brushes.Red;
                InfoLabel.Text = "Вы указали один и тот-же город.";
                return;
            }
            else
            {
                InfoLabel.Text = "";
            }

            if (IsFoundSelectedTransportation() == true)
            {
                AddMinimalWeightPriceInTextBox();
                AddWeightValuesInTextBoxs();
                AddSizeValuesInTextBoxs();
                return;
            }

            void ClearTextBoxs()
            {
                MinimalWeightPriceTextBox.Text = "";

                var allSizeTextBox = SizeTextBoxs.Children;

                short i = 0;
                foreach (var item in allSizeTextBox)
                {
                    (item as TextBox).Text = "";
                    i += 1;
                }

                var allWeightTextBox = WeightTextBoxs.Children;

                short j = 0;
                foreach (var item in allWeightTextBox)
                {
                    (item as TextBox).Text = "";
                    j += 1;
                }
            }

            bool IsFoundSelectedTransportation()
            {
                // TODO: Повтор.
                var findValue = OdbConnectHelper.dbObj.Transportation.FirstOrDefault(
                    x =>
                    x.Incity == InComboBox.SelectedItem as City &&
                    x.Fromcity == FromComboBox.SelectedItem as City
                    );

                return findValue != null;
            }
            void AddMinimalWeightPriceInTextBox()
            {
                MinimalWeightPrice MinimalWeightPriceDB = null;
                if (ActiveMode == Mode.CreateTransportation)
                {
                    var transp = OdbConnectHelper.dbObj.Transportation.FirstOrDefault(
                        x =>
                        x.Incity == InComboBox.SelectedItem as City &&
                        x.Fromcity == FromComboBox.SelectedItem as City
                    );
                    MinimalWeightPriceDB = OdbConnectHelper.dbObj.MinimalWeightPrice.FirstOrDefault(x => x.Transportation == transp);
                }
                else if (ActiveMode == Mode.EditTransportation)
                {
                    MinimalWeightPriceDB = OdbConnectHelper.dbObj.MinimalWeightPrice.FirstOrDefault(x => x.Transportation == _selectedTransportation);
                }

                string? MinimalWeightPrice = MinimalWeightPriceDB?.Price.ToString();
                if (MinimalWeightPrice == null)
                {
                    MinimalWeightPrice = "";
                }
                MinimalWeightPriceTextBox.Text = MinimalWeightPrice;
            }
            void AddSizeValuesInTextBoxs()
            {
                // TODO: Повтор.
                var transp = OdbConnectHelper.dbObj.Transportation.FirstOrDefault(
                    x =>
                    x.Incity == InComboBox.SelectedItem as City &&
                    x.Fromcity == FromComboBox.SelectedItem as City
                );

                var sizeValues = OdbConnectHelper.dbObj.SizeCoefficient.Where(
                    x => x.Transportation == transp
                ).OrderBy(x => x.SizeId).ToList();

                var allSizeTextBox = SizeTextBoxs.Children;

                short i = 0;
                foreach (var item in allSizeTextBox)
                {
                    (item as TextBox).Text = sizeValues[i].Price.ToString();
                    i += 1;
                }
            }
            void AddWeightValuesInTextBoxs()
            {
                // TODO: Повтор.
                var transp = OdbConnectHelper.dbObj.Transportation.FirstOrDefault(
                    x =>
                    x.Incity == InComboBox.SelectedItem as City &&
                    x.Fromcity == FromComboBox.SelectedItem as City
                );

                var weightValues = OdbConnectHelper.dbObj.WeightCoefficient.Where(
                    x => x.Transportation == transp
                ).OrderBy(x => x.WeightId).ToList();

                var allWeightTextBox = WeightTextBoxs.Children;

                short i = 0;
                foreach (var item in allWeightTextBox)
                {
                    (item as TextBox).Text = weightValues[i].Price.ToString();
                    i += 1;
                }
            }
        }

    }

}
