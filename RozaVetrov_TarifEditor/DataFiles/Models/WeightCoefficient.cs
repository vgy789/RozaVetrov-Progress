using System;
using System.Collections.Generic;

namespace RozaVetrov_TarifEditor.DataFiles.Models
{
    public partial class WeightCoefficient
    {
        public long WeightCoefficientId { get; set; }
        public short WeightId { get; set; }
        public int TransportationId { get; set; }
        public decimal Price { get; set; }

        public virtual Transportation Transportation { get; set; }
        public virtual Weight Weight { get; set; }
    }
}
