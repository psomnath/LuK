using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace LuK
{
    public interface IMLModel
    {
        Task<bool> FindMatch(List<AmberAlert> amberAlerts);
    }
}
