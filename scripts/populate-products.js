#!/usr/bin/env node

// Script to populate CloudMart with realistic e-commerce products
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand, BatchWriteCommand } from '@aws-sdk/lib-dynamodb';
import { v4 as uuidv4 } from 'uuid';

const client = new DynamoDBClient({ region: 'us-east-1' });
const docClient = DynamoDBDocumentClient.from(client);

const products = [
  // Electronics & Tech
  {
    name: "MacBook Pro 16-inch M3 Max",
    description: "Apple MacBook Pro with M3 Max chip, 36GB RAM, 1TB SSD. Perfect for developers and creative professionals.",
    price: 3999.99,
    category: "Electronics",
    subcategory: "Laptops",
    brand: "Apple",
    image: "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500&h=500&fit=crop",
    stock: 15,
    rating: 4.8,
    reviews: 342,
    features: ["M3 Max Chip", "36GB RAM", "1TB SSD", "16-inch Retina Display"],
    tags: ["laptop", "apple", "professional", "development"]
  },
  {
    name: "iPhone 15 Pro Max",
    description: "Latest iPhone with titanium design, A17 Pro chip, and advanced camera system.",
    price: 1199.99,
    category: "Electronics",
    subcategory: "Smartphones",
    brand: "Apple",
    image: "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=500&h=500&fit=crop",
    stock: 45,
    rating: 4.9,
    reviews: 1205,
    features: ["A17 Pro Chip", "Titanium Design", "48MP Camera", "USB-C"],
    tags: ["smartphone", "apple", "premium", "camera"]
  },
  {
    name: "Samsung Galaxy S24 Ultra",
    description: "Premium Android smartphone with S Pen, 200MP camera, and AI features.",
    price: 1299.99,
    category: "Electronics",
    subcategory: "Smartphones",
    brand: "Samsung",
    image: "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500&h=500&fit=crop",
    stock: 32,
    rating: 4.7,
    reviews: 856,
    features: ["S Pen", "200MP Camera", "AI Features", "5000mAh Battery"],
    tags: ["smartphone", "samsung", "android", "s-pen"]
  },
  {
    name: "Sony WH-1000XM5 Headphones",
    description: "Industry-leading noise canceling wireless headphones with 30-hour battery life.",
    price: 399.99,
    category: "Electronics",
    subcategory: "Audio",
    brand: "Sony",
    image: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&h=500&fit=crop",
    stock: 67,
    rating: 4.6,
    reviews: 2341,
    features: ["Noise Canceling", "30hr Battery", "Quick Charge", "Multipoint Connection"],
    tags: ["headphones", "wireless", "noise-canceling", "premium"]
  },
  {
    name: "Dell XPS 13 Plus",
    description: "Ultra-thin laptop with 13.4-inch OLED display, Intel i7, and premium build quality.",
    price: 1899.99,
    category: "Electronics",
    subcategory: "Laptops",
    brand: "Dell",
    image: "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500&h=500&fit=crop",
    stock: 23,
    rating: 4.5,
    reviews: 445,
    features: ["OLED Display", "Intel i7", "16GB RAM", "Ultra-thin Design"],
    tags: ["laptop", "dell", "oled", "ultrabook"]
  },

  // Fashion & Apparel
  {
    name: "Nike Air Jordan 1 Retro High",
    description: "Classic basketball sneakers with premium leather and iconic design.",
    price: 170.00,
    category: "Fashion",
    subcategory: "Shoes",
    brand: "Nike",
    image: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500&h=500&fit=crop",
    stock: 89,
    rating: 4.8,
    reviews: 1567,
    features: ["Premium Leather", "Air Cushioning", "Iconic Design", "Multiple Colorways"],
    tags: ["sneakers", "basketball", "retro", "streetwear"]
  },
  {
    name: "Levi's 501 Original Jeans",
    description: "The original straight fit jeans. A classic since 1873.",
    price: 89.99,
    category: "Fashion",
    subcategory: "Clothing",
    brand: "Levi's",
    image: "https://images.unsplash.com/photo-1542272604-787c3835535d?w=500&h=500&fit=crop",
    stock: 156,
    rating: 4.4,
    reviews: 3421,
    features: ["100% Cotton", "Straight Fit", "Classic Design", "Durable"],
    tags: ["jeans", "denim", "classic", "casual"]
  },
  {
    name: "Patagonia Better Sweater Fleece",
    description: "Cozy fleece jacket made from recycled polyester. Perfect for outdoor adventures.",
    price: 139.00,
    category: "Fashion",
    subcategory: "Outerwear",
    brand: "Patagonia",
    image: "https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=500&h=500&fit=crop",
    stock: 78,
    rating: 4.7,
    reviews: 892,
    features: ["Recycled Polyester", "Full-Zip", "Fleece Lining", "Sustainable"],
    tags: ["fleece", "outdoor", "sustainable", "jacket"]
  },
  {
    name: "Ray-Ban Aviator Classic",
    description: "Iconic aviator sunglasses with crystal lenses and gold frame.",
    price: 154.00,
    category: "Fashion",
    subcategory: "Accessories",
    brand: "Ray-Ban",
    image: "https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=500&h=500&fit=crop",
    stock: 234,
    rating: 4.6,
    reviews: 5678,
    features: ["Crystal Lenses", "Gold Frame", "UV Protection", "Classic Design"],
    tags: ["sunglasses", "aviator", "classic", "luxury"]
  },

  // Home & Living
  {
    name: "Dyson V15 Detect Cordless Vacuum",
    description: "Advanced cordless vacuum with laser dust detection and powerful suction.",
    price: 749.99,
    category: "Home & Garden",
    subcategory: "Appliances",
    brand: "Dyson",
    image: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500&h=500&fit=crop",
    stock: 34,
    rating: 4.5,
    reviews: 1234,
    features: ["Laser Detection", "60min Runtime", "HEPA Filtration", "Lightweight"],
    tags: ["vacuum", "cordless", "cleaning", "technology"]
  },
  {
    name: "Instant Pot Duo 7-in-1",
    description: "Multi-functional pressure cooker that replaces 7 kitchen appliances.",
    price: 99.99,
    category: "Home & Garden",
    subcategory: "Kitchen",
    brand: "Instant Pot",
    image: "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=500&h=500&fit=crop",
    stock: 67,
    rating: 4.7,
    reviews: 8945,
    features: ["7-in-1 Functions", "6 Quart Capacity", "Smart Programs", "Safe Design"],
    tags: ["pressure-cooker", "kitchen", "cooking", "appliance"]
  },
  {
    name: "Philips Hue Smart Light Starter Kit",
    description: "Smart LED bulbs with millions of colors and voice control compatibility.",
    price: 199.99,
    category: "Home & Garden",
    subcategory: "Smart Home",
    brand: "Philips",
    image: "https://images.unsplash.com/photo-1558002038-1055907df827?w=500&h=500&fit=crop",
    stock: 89,
    rating: 4.4,
    reviews: 2156,
    features: ["16M Colors", "Voice Control", "App Control", "Energy Efficient"],
    tags: ["smart-home", "lighting", "led", "automation"]
  },

  // Sports & Fitness
  {
    name: "Peloton Bike+",
    description: "Premium indoor cycling bike with rotating HD touchscreen and live classes.",
    price: 2495.00,
    category: "Sports & Outdoors",
    subcategory: "Fitness Equipment",
    brand: "Peloton",
    image: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500&h=500&fit=crop",
    stock: 12,
    rating: 4.8,
    reviews: 3456,
    features: ["HD Touchscreen", "Live Classes", "Auto Resistance", "Heart Rate Monitor"],
    tags: ["fitness", "cycling", "home-gym", "premium"]
  },
  {
    name: "Yeti Rambler 20oz Tumbler",
    description: "Insulated stainless steel tumbler that keeps drinks hot or cold for hours.",
    price: 35.00,
    category: "Sports & Outdoors",
    subcategory: "Drinkware",
    brand: "Yeti",
    image: "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500&h=500&fit=crop",
    stock: 345,
    rating: 4.9,
    reviews: 12456,
    features: ["Double-Wall Insulation", "Dishwasher Safe", "No Sweat Design", "Durable"],
    tags: ["tumbler", "insulated", "outdoor", "drinkware"]
  },
  {
    name: "Apple Watch Series 9",
    description: "Advanced smartwatch with health monitoring, GPS, and cellular connectivity.",
    price: 429.00,
    category: "Electronics",
    subcategory: "Wearables",
    brand: "Apple",
    image: "https://images.unsplash.com/photo-1434493789847-2f02dc6ca35d?w=500&h=500&fit=crop",
    stock: 78,
    rating: 4.6,
    reviews: 5678,
    features: ["Health Monitoring", "GPS + Cellular", "Always-On Display", "Water Resistant"],
    tags: ["smartwatch", "fitness", "health", "apple"]
  },

  // Books & Media
  {
    name: "The Psychology of Money",
    description: "Timeless lessons on wealth, greed, and happiness by Morgan Housel.",
    price: 16.99,
    category: "Books",
    subcategory: "Business & Finance",
    brand: "Harriman House",
    image: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&h=500&fit=crop",
    stock: 234,
    rating: 4.8,
    reviews: 8934,
    features: ["Bestseller", "Financial Wisdom", "Easy to Read", "Practical Advice"],
    tags: ["book", "finance", "psychology", "bestseller"]
  },
  {
    name: "Atomic Habits",
    description: "An easy & proven way to build good habits & break bad ones by James Clear.",
    price: 18.99,
    category: "Books",
    subcategory: "Self-Help",
    brand: "Avery",
    image: "https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=500&h=500&fit=crop",
    stock: 456,
    rating: 4.9,
    reviews: 15678,
    features: ["#1 Bestseller", "Habit Formation", "Practical Strategies", "Life-Changing"],
    tags: ["book", "habits", "self-help", "productivity"]
  },

  // Beauty & Personal Care
  {
    name: "Olaplex Hair Perfector No. 3",
    description: "At-home hair treatment that reduces breakage and strengthens hair.",
    price: 28.00,
    category: "Beauty & Personal Care",
    subcategory: "Hair Care",
    brand: "Olaplex",
    image: "https://images.unsplash.com/photo-1526045478516-99145907023c?w=500&h=500&fit=crop",
    stock: 167,
    rating: 4.5,
    reviews: 3456,
    features: ["Strengthens Hair", "Reduces Breakage", "Professional Formula", "Easy to Use"],
    tags: ["hair-care", "treatment", "professional", "beauty"]
  },
  {
    name: "The Ordinary Niacinamide 10% + Zinc 1%",
    description: "High-strength vitamin and mineral blemish formula for clearer skin.",
    price: 7.90,
    category: "Beauty & Personal Care",
    subcategory: "Skincare",
    brand: "The Ordinary",
    image: "https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=500&h=500&fit=crop",
    stock: 289,
    rating: 4.3,
    reviews: 7890,
    features: ["10% Niacinamide", "Zinc Formula", "Blemish Control", "Affordable"],
    tags: ["skincare", "serum", "acne", "affordable"]
  },

  // Gaming
  {
    name: "PlayStation 5 Console",
    description: "Next-gen gaming console with ultra-high speed SSD and ray tracing.",
    price: 499.99,
    category: "Electronics",
    subcategory: "Gaming",
    brand: "Sony",
    image: "https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?w=500&h=500&fit=crop",
    stock: 8,
    rating: 4.8,
    reviews: 4567,
    features: ["Ultra-High Speed SSD", "Ray Tracing", "3D Audio", "DualSense Controller"],
    tags: ["gaming", "console", "playstation", "next-gen"]
  },
  {
    name: "Nintendo Switch OLED",
    description: "Portable gaming console with vibrant OLED screen and enhanced audio.",
    price: 349.99,
    category: "Electronics",
    subcategory: "Gaming",
    brand: "Nintendo",
    image: "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=500&h=500&fit=crop",
    stock: 45,
    rating: 4.7,
    reviews: 2345,
    features: ["OLED Screen", "Portable Gaming", "Enhanced Audio", "64GB Storage"],
    tags: ["gaming", "portable", "nintendo", "oled"]
  }
];

async function populateProducts() {
  console.log('🚀 Starting to populate CloudMart with realistic products...');
  
  try {
    // Process products in batches of 25 (DynamoDB batch limit)
    const batchSize = 25;
    for (let i = 0; i < products.length; i += batchSize) {
      const batch = products.slice(i, i + batchSize);
      
      const putRequests = batch.map(product => ({
        PutRequest: {
          Item: {
            id: uuidv4(),
            ...product,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
            isActive: true,
            sku: `CM-${Math.random().toString(36).substr(2, 9).toUpperCase()}`,
            weight: Math.round((Math.random() * 5 + 0.1) * 100) / 100, // Random weight 0.1-5kg
            dimensions: {
              length: Math.round(Math.random() * 50 + 5), // 5-55cm
              width: Math.round(Math.random() * 40 + 5),  // 5-45cm
              height: Math.round(Math.random() * 30 + 2)  // 2-32cm
            },
            shipping: {
              freeShipping: product.price > 50,
              estimatedDays: Math.floor(Math.random() * 5) + 1, // 1-5 days
              cost: product.price > 50 ? 0 : Math.round(Math.random() * 15 + 5) // $5-20
            }
          }
        }
      }));

      const params = {
        RequestItems: {
          'cloudmart-products': putRequests
        }
      };

      await docClient.send(new BatchWriteCommand(params));
      console.log(`✅ Batch ${Math.floor(i/batchSize) + 1} completed (${batch.length} products)`);
      
      // Small delay to avoid throttling
      await new Promise(resolve => setTimeout(resolve, 100));
    }

    console.log(`🎉 Successfully populated ${products.length} products in CloudMart!`);
    console.log('📊 Product categories added:');
    
    const categories = [...new Set(products.map(p => p.category))];
    categories.forEach(cat => {
      const count = products.filter(p => p.category === cat).length;
      console.log(`   • ${cat}: ${count} products`);
    });

    console.log('\n🌐 Your e-commerce application now has realistic product data!');
    console.log('🔗 Visit your frontend to see the products in action.');
    
  } catch (error) {
    console.error('❌ Error populating products:', error);
    process.exit(1);
  }
}

// Run the script
populateProducts();
