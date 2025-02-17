using System;
using System.Collections.Generic;

namespace RozaVetrov_TarifEditor.DataFiles.Models
{
    public partial class User
    {
        public int UserId { get; set; }
        public string Login { get; set; }
        public string Password { get; set; }
        public string Name { get; set; }
    }
}
