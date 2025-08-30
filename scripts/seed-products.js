#!/usr/bin/env node

const axios = require('axios');

// Configuration
const API_BASE_URL = process.env.API_BASE_URL || 'http://localhost:3001/api';

// Stunning product catalog with high-quality images
const products = [
  // Electronics & Tech
  {
    name: "MacBook Pro 16-inch M3 Max",
    description: "Apple MacBook Pro with M3 Max chip, 36GB RAM, 1TB SSD. Perfect for professionals and creators.",
    price: 3999.99,
    image: "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "iPhone 15 Pro Max",
    description: "Latest iPhone with titanium design, A17 Pro chip, and advanced camera system.",
    price: 1199.99,
    image: "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "Sony WH-1000XM5 Headphones",
    description: "Industry-leading noise canceling wireless headphones with 30-hour battery life.",
    price: 399.99,
    image: "https://images.unsplash.com/photo-1583394838336-acd977736f90?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "Samsung 65\" OLED 4K TV",
    description: "Stunning OLED display with perfect blacks, vibrant colors, and smart TV features.",
    price: 2499.99,
    image: "https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "iPad Pro 12.9-inch",
    description: "Powerful tablet with M2 chip, Liquid Retina XDR display, and Apple Pencil support.",
    price: 1099.99,
    image: "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=800&h=600&fit=crop&crop=center"
  },

  // Fashion & Apparel
  {
    name: "Premium Leather Jacket",
    description: "Handcrafted genuine leather jacket with classic design and premium finish.",
    price: 299.99,
    image: "https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "Designer Sneakers",
    description: "Limited edition designer sneakers with premium materials and comfort technology.",
    price: 189.99,
    image: "https://images.unsplash.com/photo-1549298916-b41d501d3772?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "Luxury Swiss Watch",
    description: "Elegant Swiss-made timepiece with automatic movement and sapphire crystal.",
    price: 1299.99,
    image: "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "Cashmere Wool Sweater",
    description: "Ultra-soft cashmere blend sweater in classic fit with premium quality.",
    price: 149.99,
    image: "https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "Designer Sunglasses",
    description: "Premium polarized sunglasses with UV protection and stylish frame design.",
    price: 249.99,
    image: "https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=800&h=600&fit=crop&crop=center"
  },

  // Home & Living
  {
    name: "Modern Coffee Machine",
    description: "Professional-grade espresso machine with built-in grinder and milk frother.",
    price: 899.99,
    image: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "Scandinavian Dining Table",
    description: "Solid oak dining table with minimalist Scandinavian design for 6 people.",
    price: 799.99,
    image: "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "Smart Home Security System",
    description: "Complete wireless security system with cameras, sensors, and mobile app control.",
    price: 599.99,
    image: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "Luxury Bedding Set",
    description: "Egyptian cotton bedding set with 1000 thread count for ultimate comfort.",
    price: 199.99,
    image: "https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "Robot Vacuum Cleaner",
    description: "Smart robot vacuum with mapping technology and app control for effortless cleaning.",
    price: 449.99,
    image: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=600&fit=crop&crop=center"
  },

  // Sports & Fitness
  {
    name: "Professional Road Bike",
    description: "Carbon fiber road bike with Shimano components and aerodynamic design.",
    price: 2199.99,
    image: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "Yoga Mat Premium",
    description: "Eco-friendly yoga mat with superior grip and cushioning for all practice levels.",
    price: 79.99,
    image: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "Fitness Tracker Watch",
    description: "Advanced fitness tracker with heart rate monitoring, GPS, and 7-day battery life.",
    price: 299.99,
    image: "https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "Adjustable Dumbbells Set",
    description: "Space-saving adjustable dumbbells with quick-change weight system (5-50 lbs each).",
    price: 399.99,
    image: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "Running Shoes",
    description: "High-performance running shoes with advanced cushioning and breathable design.",
    price: 159.99,
    image: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&h=600&fit=crop&crop=center"
  },

  // Beauty & Personal Care
  {
    name: "Skincare Gift Set",
    description: "Luxury skincare collection with cleanser, serum, moisturizer, and eye cream.",
    price: 149.99,
    image: "https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "Professional Hair Dryer",
    description: "Ionic hair dryer with multiple heat settings and concentrator nozzle.",
    price: 129.99,
    image: "https://images.unsplash.com/photo-1522338242992-e1a54906a8da?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "Electric Toothbrush",
    description: "Smart electric toothbrush with pressure sensor and multiple cleaning modes.",
    price: 89.99,
    image: "https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "Perfume Collection",
    description: "Luxury fragrance set with three signature scents in elegant bottles.",
    price: 199.99,
    image: "https://images.unsplash.com/photo-1541643600914-78b084683601?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "Makeup Brush Set",
    description: "Professional makeup brush collection with synthetic bristles and elegant handles.",
    price: 79.99,
    image: "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=800&h=600&fit=crop&crop=center"
  },

  // Books & Education
  {
    name: "Programming Books Collection",
    description: "Essential programming books covering JavaScript, Python, and system design.",
    price: 99.99,
    image: "https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "Digital Drawing Tablet",
    description: "Professional drawing tablet with pressure-sensitive stylus for digital artists.",
    price: 349.99,
    image: "https://images.unsplash.com/photo-1586953208448-b95a79798f07?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "Wireless Keyboard & Mouse",
    description: "Ergonomic wireless keyboard and mouse combo with long battery life.",
    price: 129.99,
    image: "https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "Desk Organizer Set",
    description: "Bamboo desk organizer with compartments for pens, papers, and accessories.",
    price: 49.99,
    image: "https://images.unsplash.com/photo-1586953208448-b95a79798f07?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "LED Desk Lamp",
    description: "Adjustable LED desk lamp with touch control and USB charging port.",
    price: 69.99,
    image: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&h=600&fit=crop&crop=center"
  },

  // Kitchen & Dining
  {
    name: "Chef's Knife Set",
    description: "Professional chef's knife set with German steel blades and ergonomic handles.",
    price: 199.99,
    image: "https://images.unsplash.com/photo-1593618998160-e34014e67546?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "Stand Mixer",
    description: "Heavy-duty stand mixer with multiple attachments for baking and cooking.",
    price: 399.99,
    image: "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "Non-Stick Cookware Set",
    description: "Complete non-stick cookware set with pots, pans, and cooking utensils.",
    price: 249.99,
    image: "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "Wine Glasses Set",
    description: "Crystal wine glasses set of 6 with elegant design for special occasions.",
    price: 89.99,
    image: "https://images.unsplash.com/photo-1510972527921-ce03766a1cf1?w=800&h=600&fit=crop&crop=center"
  },
  {
    name: "Ceramic Dinnerware Set",
    description: "Modern ceramic dinnerware set for 8 people with plates, bowls, and mugs.",
    price: 159.99,
    image: "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=600&fit=crop&crop=center"
  }
];

async function seedProducts() {
  console.log('🚀 Starting product seeding for CloudMart...');
  console.log(`📡 API Base URL: ${API_BASE_URL}`);
  
  let successCount = 0;
  let errorCount = 0;

  for (let i = 0; i < products.length; i++) {
    const product = products[i];
    try {
      console.log(`📦 Adding product ${i + 1}/${products.length}: ${product.name}`);
      
      const response = await axios.post(`${API_BASE_URL}/products`, product, {
        headers: {
          'Content-Type': 'application/json',
        },
        timeout: 10000, // 10 second timeout
      });
      
      if (response.status === 200 || response.status === 201) {
        console.log(`✅ Successfully added: ${product.name}`);
        successCount++;
      } else {
        console.log(`⚠️  Unexpected response for ${product.name}: ${response.status}`);
        errorCount++;
      }
      
      // Small delay to avoid overwhelming the API
      await new Promise(resolve => setTimeout(resolve, 100));
      
    } catch (error) {
      console.error(`❌ Failed to add ${product.name}:`, error.message);
      errorCount++;
      
      // Continue with next product instead of stopping
      continue;
    }
  }

  console.log('\n🎉 Product seeding completed!');
  console.log(`✅ Successfully added: ${successCount} products`);
  console.log(`❌ Failed to add: ${errorCount} products`);
  console.log(`📊 Total products processed: ${products.length}`);
  
  if (successCount > 0) {
    console.log('\n🛍️  Your CloudMart now has stunning products ready for customers!');
    console.log('🔗 Visit your admin panel to see all the new products.');
  }
}

// Handle command line execution
if (require.main === module) {
  seedProducts().catch(error => {
    console.error('💥 Fatal error during seeding:', error);
    process.exit(1);
  });
}

module.exports = { products, seedProducts };
