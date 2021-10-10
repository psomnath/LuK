using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using SQLite;

namespace LuK
{
    public class LocalDatabase
    {
        private readonly SQLiteAsyncConnection _database;
        public LocalDatabase(string dbpath)
        {
            _database = new SQLiteAsyncConnection(dbpath);
            _database.CreateTableAsync<AmberAlert>();
        }

        public Task<List<AmberAlert>> GetAmberAlertAsync()
        {
            return _database.Table<AmberAlert>().ToListAsync();
        }

        public Task<int> SaveAmberAlertAsync(List<AmberAlert> alerts)
        {
            return _database.InsertAllAsync(alerts);
        }
    }
}
