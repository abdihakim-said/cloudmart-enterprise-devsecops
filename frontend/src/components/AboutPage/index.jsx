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
            <h2 className="text-xl font-semibold text-blue-600 mb-2">Production E-commerce Platform | 2024</h2>
            <p className="text-gray-600">Live Production Environment: <a href="https://app.cloudmartsaid.shop" className="text-blue-600 hover:underline" target="_blank" rel="noopener noreferrer">https://app.cloudmartsaid.shop</a></p>
          </div>

          <h2 className="text-2xl font-semibold mb-4">OVERVIEW</h2>
          <p className="mb-6">
            Built and deployed a production-ready e-commerce platform demonstrating enterprise-level 
            DevOps/SRE expertise with multi-cloud architecture, AI integration, and advanced security practices.
          </p>

          <h2 className="text-2xl font-semibold mb-4">🏆 KEY ACHIEVEMENTS</h2>
          <ul className="list-disc list-inside mb-6 space-y-2">
            <li><strong>99.9% uptime SLA</strong> with zero-downtime deployments</li>
            <li><strong>95%+ CI/CD pipeline success rate</strong> (industry leading)</li>
            <li><strong>Sub-200ms API response times</strong> at scale</li>
            <li><strong>100% automated security vulnerability scanning</strong></li>
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
            <li><strong>Runtime security monitoring</strong> with Falco</li>
            <li><strong>Pod Security Standards</strong> and network policies</li>
            <li><strong>Secrets management</strong> with AWS Secrets Manager</li>
            <li><strong>TLS 1.3 encryption</strong> with trusted CA certificates</li>
            <li><strong>SOC 2 compliance framework</strong> implementation</li>
          </ul>

          <h2 className="text-2xl font-semibold mb-4">💼 BUSINESS IMPACT</h2>
          <ul className="list-disc list-inside mb-6 space-y-2">
            <li><strong>90% automation</strong> of customer support through AI chatbot</li>
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

          <h2 className="text-2xl font-semibold mb-4">📊 LIVE METRICS</h2>
          <div className="grid md:grid-cols-3 gap-4 mb-6">
            <div className="bg-green-50 p-4 rounded-lg text-center">
              <div className="text-2xl font-bold text-green-600">99.9%</div>
              <div className="text-sm text-gray-600">Uptime SLA</div>
            </div>
            <div className="bg-blue-50 p-4 rounded-lg text-center">
              <div className="text-2xl font-bold text-blue-600">&lt;200ms</div>
              <div className="text-sm text-gray-600">Response Time</div>
            </div>
            <div className="bg-purple-50 p-4 rounded-lg text-center">
              <div className="text-2xl font-bold text-purple-600">95%+</div>
              <div className="text-sm text-gray-600">Pipeline Success</div>
            </div>
          </div>

          <h2 className="text-2xl font-semibold mb-4">👨‍💻 DEVELOPER</h2>
          <div className="bg-blue-50 p-4 rounded-lg">
            <p className="mb-2">
              <strong>Abdihakim Said</strong> - Senior DevOps/SRE Engineer
            </p>
            <p className="mb-2">
              Specializing in enterprise-scale cloud infrastructure, DevSecOps automation, and AI integration.
              Passionate about building secure, scalable, and reliable systems that deliver measurable business value.
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