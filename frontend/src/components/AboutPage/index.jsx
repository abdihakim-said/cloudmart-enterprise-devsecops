import React from 'react';
import Header from '../Header';
import Footer from '../Footer';

const AboutPage = () => {
  return (
    <div className="min-h-screen bg-gray-100 flex flex-col">
      <Header showSearch={false} />
      <main className="container mx-auto py-8 flex-grow">
        <h1 className="text-3xl font-bold mb-6">CloudMart - Enterprise Multi-Cloud DevSecOps Platform</h1>
        <div className="bg-white rounded-lg shadow-md p-6">
          <div className="mb-6">
            <h2 className="text-xl font-semibold text-blue-600 mb-2">Portfolio E-commerce Build | 2025</h2>
            <p className="text-gray-600">Demo environment (decommissioned): <a href="https://app.cloudmartsaid.shop" className="text-blue-600 hover:underline" target="_blank" rel="noopener noreferrer">https://app.cloudmartsaid.shop</a></p>
          </div>

          <h2 className="text-2xl font-semibold mb-4">OVERVIEW</h2>
          <p className="mb-6">
            CloudMart is a modern e-commerce platform built to demonstrate enterprise-level cloud architecture 
            and DevSecOps practices. Our platform provides a seamless shopping experience while showcasing 
            advanced cloud technologies, AI integration, and security best practices.
          </p>

          <h2 className="text-2xl font-semibold mb-4">🛍️ WHAT WE OFFER</h2>
          <div className="grid md:grid-cols-2 gap-6 mb-6">
            <div>
              <h3 className="font-semibold mb-2 text-blue-600">Product Catalog</h3>
              <ul className="list-disc list-inside space-y-1 text-sm">
                <li>Curated selection of technology products</li>
                <li>Real-time inventory management</li>
                <li>Advanced search and filtering</li>
                <li>Product recommendations</li>
              </ul>
            </div>
            <div>
              <h3 className="font-semibold mb-2 text-blue-600">AI-Powered Features</h3>
              <ul className="list-disc list-inside space-y-1 text-sm">
                <li>Intelligent customer support chatbot</li>
                <li>Sentiment analysis for feedback</li>
                <li>Personalized shopping experience</li>
                <li>Automated order processing</li>
              </ul>
            </div>
          </div>

          <h2 className="text-2xl font-semibold mb-4">🏪 CLOUDMART EXPERIENCE</h2>
          <div className="bg-blue-50 p-4 rounded-lg mb-6">
            <h3 className="font-semibold mb-2">Shop with Confidence</h3>
            <p className="text-sm mb-2">
              Browse our technology catalog featuring laptops, smartphones, accessories, and more. 
              Each product is carefully selected to demonstrate real e-commerce functionality.
            </p>
            <h3 className="font-semibold mb-2">AI Assistant Support</h3>
            <p className="text-sm mb-2">
              Get instant help from our AI-powered customer support. Ask questions about products, 
              orders, or get personalized recommendations powered by OpenAI and AWS Bedrock.
            </p>
            <h3 className="font-semibold mb-2">Secure & Reliable</h3>
            <p className="text-sm">
              Shop with confidence knowing your data is protected by enterprise-grade security, 
              encrypted transactions, and reliable cloud infrastructure.
            </p>
          </div>

          <h2 className="text-2xl font-semibold mb-4">🏆 KEY ACHIEVEMENTS</h2>
          <ul className="list-disc list-inside mb-6 space-y-2">
            <li><strong>Rolling deployments</strong> to EKS from the CI/CD pipeline</li>
            <li><strong>Security gate</strong> that blocks the build on leaked secrets and critical CVEs</li>
            <li><strong>Sub-200ms API response times</strong> at scale</li>
            <li><strong>7 security scanners</strong> in every pipeline run</li>
            <li><strong>Multiple daily deployments</strong> with automated rollback</li>
          </ul>

          <h2 className="text-2xl font-semibold mb-4">🛠️ TECHNICAL IMPLEMENTATION</h2>
          <div className="grid md:grid-cols-2 gap-6 mb-6">
            <div>
              <ul className="list-disc list-inside space-y-2">
                <li><strong>Multi-Cloud Architecture:</strong> AWS (primary), Azure (AI services), GCP (analytics)</li>
                <li><strong>Container Orchestration:</strong> Kubernetes (EKS) with auto-scaling and load balancing</li>
                <li><strong>Infrastructure as Code:</strong> Terraform with state management and compliance scanning</li>
              </ul>
            </div>
            <div>
              <ul className="list-disc list-inside space-y-2">
                <li><strong>DevSecOps Pipeline:</strong> Integrated security scanning (GitLeaks, Semgrep, Trivy, Checkov)</li>
                <li><strong>AI Integration:</strong> OpenAI GPT-4, AWS Bedrock, Azure Cognitive Services</li>
                <li><strong>Monitoring Stack:</strong> Prometheus, Grafana, Falco for comprehensive observability</li>
              </ul>
            </div>
          </div>

          <h2 className="text-2xl font-semibold mb-4">🔒 SECURITY & COMPLIANCE</h2>
          <ul className="list-disc list-inside mb-6 space-y-2">
            <li><strong>Falco runtime detection rules</strong></li>
            <li><strong>Pod Security Standards</strong> and network policies</li>
            <li><strong>Secrets management</strong> with AWS Secrets Manager</li>
            <li><strong>TLS 1.3 encryption</strong> with trusted CA certificates</li>
          </ul>

          <h2 className="text-2xl font-semibold mb-4">💼 BUSINESS IMPACT</h2>
          <ul className="list-disc list-inside mb-6 space-y-2">
            <li><strong>AI support assistant</strong> with sentiment analysis on tickets</li>
            <li><strong>Cost optimization</strong> through intelligent auto-scaling</li>
            <li><strong>Enhanced security posture</strong> with zero critical vulnerabilities</li>
            <li><strong>Improved developer productivity</strong> with streamlined CI/CD</li>
          </ul>

          <h2 className="text-2xl font-semibold mb-4">⚡ TECHNOLOGIES</h2>
          <div className="bg-gray-50 p-4 rounded-lg mb-6">
            <p className="text-sm">
              <strong>Cloud & Infrastructure:</strong> AWS, Azure, GCP, Kubernetes, Docker, Terraform<br/>
              <strong>Application Stack:</strong> Node.js, React, DynamoDB, Express.js<br/>
              <strong>Monitoring & Security:</strong> Prometheus, Grafana, Falco, GitLeaks, Trivy<br/>
              <strong>AI & Analytics:</strong> OpenAI API, AWS Bedrock, Azure Cognitive Services<br/>
              <strong>DevSecOps Tools:</strong> Semgrep, Checkov, AWS Secrets Manager
            </p>
          </div>

          <h2 className="text-2xl font-semibold mb-4">🎯 WHY CHOOSE CLOUDMART</h2>
          <div className="grid md:grid-cols-3 gap-4 mb-6">
            <div className="bg-green-50 p-4 rounded-lg text-center">
              <div className="text-2xl font-bold text-green-600 mb-2">🚀</div>
              <div className="font-semibold mb-1">Fast & Reliable</div>
              <div className="text-sm text-gray-600">Latency and error rates tracked in Prometheus and Grafana</div>
            </div>
            <div className="bg-blue-50 p-4 rounded-lg text-center">
              <div className="text-2xl font-bold text-blue-600 mb-2">🤖</div>
              <div className="font-semibold mb-1">AI-Powered</div>
              <div className="text-sm text-gray-600">Smart recommendations and instant support</div>
            </div>
            <div className="bg-purple-50 p-4 rounded-lg text-center">
              <div className="text-2xl font-bold text-purple-600 mb-2">🔒</div>
              <div className="font-semibold mb-1">Enterprise Security</div>
              <div className="text-sm text-gray-600">Bank-level encryption and data protection</div>
            </div>
          </div>

          <h2 className="text-2xl font-semibold mb-4">👨‍💻 DEVELOPER</h2>
          <div className="bg-blue-50 p-4 rounded-lg">
            <p className="mb-2">
              <strong>Abdihakim Said</strong> - Senior DevOps/SRE Engineer
            </p>
            <p className="mb-2">
              Specializing in enterprise-scale cloud infrastructure, DevSecOps automation, and AI integration.
              Passionate about building secure, scalable, and reliable systems that deliver outstanding business value.
            </p>
            <p>
              <strong>Connect:</strong> 
              <a href="https://linkedin.com/in/said-devops" className="text-blue-600 hover:underline ml-2" target="_blank" rel="noopener noreferrer">LinkedIn</a> | 
              <a href="mailto:abdihakimsaid1@gmail.com" className="text-blue-600 hover:underline ml-2">abdihakimsaid1@gmail.com</a>
            </p>
          </div>
        </div>
      </main>
      <Footer />
    </div>
  );
};

export default AboutPage;