using System;
using System.Collections.Generic;

namespace DB_DataEditor.DataFiles.Models
{
    public partial class City
    {
        public City()
        {
            TransportationFromcity = new HashSet<Transportation>();
            TransportationIncity = new HashSet<Transportation>();
        }

        public short CityId { get; set; }
        public string Name { get; set; }
        public short SubjectId { get; set; }

        public virtual Subject Subject { get; set; }
        public virtual ICollection<Transportation> TransportationFromcity { get; set; }
        public virtual ICollection<Transportation> TransportationIncity { get; set; }
    }
}
