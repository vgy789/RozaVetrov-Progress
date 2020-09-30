using System;
using System.Collections.Generic;

namespace DB_DataEditor.DataFiles.Models
{
    public partial class User
    {
        public int UserId { get; set; }
        public int RoleId { get; set; }
        public string Login { get; set; }
        public string Password { get; set; }
        public string Name { get; set; }

        public virtual Role Role { get; set; }
    }
}
