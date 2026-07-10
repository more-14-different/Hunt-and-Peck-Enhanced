using HuntAndPeck.Models;
using HuntAndPeck.Properties;

using System.Windows.Media;

namespace HuntAndPeck.ViewModels
{
    public class HintViewModel : NotifyPropertyChanged
    {
        private string _label;
        private bool _active;
        private string _fontSizeReadValue;
        private string _fontFamilyReadValue;
        private string _backgroundColorReadValue;
        private string _inactiveBackgroundColorReadValue;
        private string _textColorReadValue;
        private Brush _backgroundBrush;
        private Brush _inactiveBackgroundBrush;
        private Brush _textBrush;

        public HintViewModel(Hint hint)
        {
            Hint = hint;
            FontSizeReadValue = Settings.Default.FontSize;
            FontFamilyReadValue = Settings.Default.FontFamily;
            BackgroundColorReadValue = Settings.Default.BackgroundColor;
            InactiveBackgroundColorReadValue = Settings.Default.InactiveBackgroundColor;
            TextColorReadValue = Settings.Default.TextColor;
            BackgroundBrush = CreateBrush(BackgroundColorReadValue);
            InactiveBackgroundBrush = CreateBrush(InactiveBackgroundColorReadValue);
            TextBrush = CreateBrush(TextColorReadValue);
        }

        public Hint Hint { get; set; }

        public bool Active
        {
            get { return _active; }
            set
            {
                _active = value;
                NotifyOfPropertyChange();
                NotifyOfPropertyChange("CurrentBackgroundBrush");
            }
        }

        public string Label
        {
            get { return _label; }
            set { _label = value; NotifyOfPropertyChange(); }
        }

        public string FontSizeReadValue
        {
            get { return _fontSizeReadValue; }
            set { _fontSizeReadValue = value; NotifyOfPropertyChange(); }
        }

        public string FontFamilyReadValue
        {
            get { return _fontFamilyReadValue; }
            set { _fontFamilyReadValue = value; NotifyOfPropertyChange(); }
        }

        public string BackgroundColorReadValue
        {
            get { return _backgroundColorReadValue; }
            set { _backgroundColorReadValue = value; NotifyOfPropertyChange(); }
        }

        public string InactiveBackgroundColorReadValue
        {
            get { return _inactiveBackgroundColorReadValue; }
            set { _inactiveBackgroundColorReadValue = value; NotifyOfPropertyChange(); }
        }

        public string TextColorReadValue
        {
            get { return _textColorReadValue; }
            set { _textColorReadValue = value; NotifyOfPropertyChange(); }
        }

        public Brush BackgroundBrush
        {
            get { return _backgroundBrush; }
            set { _backgroundBrush = value; NotifyOfPropertyChange(); NotifyOfPropertyChange("CurrentBackgroundBrush"); }
        }

        public Brush InactiveBackgroundBrush
        {
            get { return _inactiveBackgroundBrush; }
            set { _inactiveBackgroundBrush = value; NotifyOfPropertyChange(); NotifyOfPropertyChange("CurrentBackgroundBrush"); }
        }

        public Brush CurrentBackgroundBrush
        {
            get { return Active ? BackgroundBrush : InactiveBackgroundBrush; }
        }

        public Brush TextBrush
        {
            get { return _textBrush; }
            set { _textBrush = value; NotifyOfPropertyChange(); }
        }

        private static Brush CreateBrush(string color)
        {
            try
            {
                var brush = new SolidColorBrush((Color)ColorConverter.ConvertFromString(color));
                brush.Freeze();
                return brush;
            }
            catch
            {
                return Brushes.Black;
            }
        }
    }
}
