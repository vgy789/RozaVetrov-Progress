using System;
using System.Collections.Generic;

namespace RozaVetrov_TarifEditor.DataFiles.Models
{
    public partial class SizeCoefficient
    {
        public long SizeCoefficientId { get; set; }
        public short SizeId { get; set; }
        public int TransportationId { get; set; }
        public int Price { get; set; }

        public virtual Size Size { get; set; }
        public virtual Transportation Transportation { get; set; }
    }
}
