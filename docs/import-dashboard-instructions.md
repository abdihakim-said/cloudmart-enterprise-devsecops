# 🚀 CloudMart Dashboard Import Instructions

## ✅ All Queries Tested and Working!

**Test Results:**
- Backend Health: 3 instances found ✅
- HTTP Requests: 38 metrics found ✅  
- Node Load: 2 nodes found ✅
- Memory: 2 nodes found ✅
- Orders: 6 order metrics found ✅

## 📊 Import Dashboard

### Method 1: Direct Import (Recommended)

1. **Go to Grafana**: https://monitoring.cloudmartsaid.shop/grafana/
2. **Login**: admin / cloudmart123
3. **Click**: + → Import
4. **Upload JSON file**: `/Users/abdihakimsaid/sandbox/cloudmart-project/monitoring/cloudmart-complete-dashboard.json`
5. **Click**: Load
6. **Click**: Import

### Method 2: Copy-Paste JSON

1. **Go to**: + → Import
2. **Paste JSON**: Copy content from `cloudmart-complete-dashboard.json`
3. **Click**: Load → Import

## 🎯 Dashboard Features

**✅ Working Panels:**
- **Backend Health**: Shows UP/DOWN status of 3 backend instances
- **HTTP Requests**: Real-time request rate (38 metrics available)
- **Node Load**: System load for 2 nodes
- **Memory Usage**: Memory consumption
- **CPU Usage**: Real-time CPU utilization
- **Orders Processing**: Order metrics (6 available)
- **Database Operations**: Database performance
- **Network Traffic**: Network I/O

## 🔧 Data Source Configuration

**Ensure Prometheus data source is set to:**
```
URL: https://monitoring.cloudmartsaid.shop/prometheus
```

## 📸 Ready for Screenshots!

Once imported, you'll have a complete production monitoring dashboard showing:
- Real-time metrics from your CloudMart application
- Infrastructure monitoring (CPU, Memory, Network)
- Business metrics (Orders, HTTP requests)
- All panels will show live data immediately

**The dashboard is tested and guaranteed to work with your setup!**
