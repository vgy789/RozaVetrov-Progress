using System;
using System.Collections.Generic;

namespace DB_DataEditor.DataFiles.Models
{
    public partial class Subject
    {
        public Subject()
        {
            City = new HashSet<City>();
        }

        public short SubjectId { get; set; }
        public string Name { get; set; }

        public virtual ICollection<City> City { get; set; }
    }
}
