#!/usr/bin/env python3
"""
CloudMart Security Report Generator
Aggregates security scan results and generates comprehensive reports
"""

import json
import argparse
import os
import sys
from datetime import datetime
from pathlib import Path

class SecurityReportGenerator:
    def __init__(self):
        self.report_data = {
            "scan_date": datetime.now().isoformat(),
            "project": "CloudMart",
            "version": "1.0.0",
            "overall_score": 0,
            "sast": {"status": "UNKNOWN", "critical": 0, "high": 0, "medium": 0, "low": 0},
            "deps": {"status": "UNKNOWN", "critical": 0, "high": 0, "medium": 0, "low": 0},
            "containers": {"status": "UNKNOWN", "critical": 0, "high": 0, "medium": 0, "low": 0},
            "dast": {"status": "UNKNOWN", "critical": 0, "high": 0, "medium": 0, "low": 0},
            "iac": {"status": "UNKNOWN", "critical": 0, "high": 0, "medium": 0, "low": 0},
            "secrets": {"status": "UNKNOWN", "findings": 0},
            "compliance": {"status": "UNKNOWN", "passed": 0, "failed": 0},
            "recommendations": []
        }

    def parse_trivy_results(self, file_path):
        """Parse Trivy SARIF results"""
        try:
            with open(file_path, 'r') as f:
                data = json.load(f)
            
            critical = high = medium = low = 0
            
            for run in data.get('runs', []):
                for result in run.get('results', []):
                    level = result.get('level', 'note')
                    if level == 'error':
                        critical += 1
                    elif level == 'warning':
                        high += 1
                    elif level == 'note':
                        medium += 1
                    else:
                        low += 1
            
            self.report_data['containers'] = {
                "status": "PASS" if critical == 0 and high == 0 else "FAIL",
                "critical": critical,
                "high": high,
                "medium": medium,
                "low": low
            }
            
            if critical > 0:
                self.report_data['recommendations'].append(
                    "Critical container vulnerabilities found. Update base images and dependencies."
                )
                
        except FileNotFoundError:
            print(f"Warning: Trivy results file not found: {file_path}")
        except Exception as e:
            print(f"Error parsing Trivy results: {e}")

    def parse_semgrep_results(self, file_path):
        """Parse Semgrep SARIF results"""
        try:
            with open(file_path, 'r') as f:
                data = json.load(f)
            
            critical = high = medium = low = 0
            
            for run in data.get('runs', []):
                for result in run.get('results', []):
                    rule_id = result.get('ruleId', '')
                    if 'security' in rule_id.lower():
                        if 'critical' in rule_id.lower():
                            critical += 1
                        elif 'high' in rule_id.lower():
                            high += 1
                        elif 'medium' in rule_id.lower():
                            medium += 1
                        else:
                            low += 1
            
            self.report_data['sast'] = {
                "status": "PASS" if critical == 0 and high == 0 else "FAIL",
                "critical": critical,
                "high": high,
                "medium": medium,
                "low": low
            }
            
            if critical > 0:
                self.report_data['recommendations'].append(
                    "Critical SAST issues found. Review and fix security vulnerabilities in code."
                )
                
        except FileNotFoundError:
            print(f"Warning: Semgrep results file not found: {file_path}")
        except Exception as e:
            print(f"Error parsing Semgrep results: {e}")

    def parse_dependency_check_results(self, file_path):
        """Parse OWASP Dependency Check results"""
        try:
            with open(file_path, 'r') as f:
                data = json.load(f)
            
            critical = high = medium = low = 0
            
            for dependency in data.get('dependencies', []):
                for vulnerability in dependency.get('vulnerabilities', []):
                    cvss_score = vulnerability.get('cvssv3', {}).get('baseScore', 0)
                    if cvss_score >= 9.0:
                        critical += 1
                    elif cvss_score >= 7.0:
                        high += 1
                    elif cvss_score >= 4.0:
                        medium += 1
                    else:
                        low += 1
            
            self.report_data['deps'] = {
                "status": "PASS" if critical == 0 and high == 0 else "FAIL",
                "critical": critical,
                "high": high,
                "medium": medium,
                "low": low
            }
            
            if critical > 0:
                self.report_data['recommendations'].append(
                    "Critical dependency vulnerabilities found. Update vulnerable packages."
                )
                
        except FileNotFoundError:
            print(f"Warning: Dependency check results file not found: {file_path}")
        except Exception as e:
            print(f"Error parsing dependency check results: {e}")

    def parse_zap_results(self, file_path):
        """Parse OWASP ZAP results"""
        try:
            with open(file_path, 'r') as f:
                data = json.load(f)
            
            critical = high = medium = low = 0
            
            for site in data.get('site', []):
                for alert in site.get('alerts', []):
                    risk = alert.get('riskdesc', '').lower()
                    if 'high' in risk:
                        high += 1
                    elif 'medium' in risk:
                        medium += 1
                    elif 'low' in risk:
                        low += 1
            
            self.report_data['dast'] = {
                "status": "PASS" if critical == 0 and high == 0 else "FAIL",
                "critical": critical,
                "high": high,
                "medium": medium,
                "low": low
            }
            
            if high > 0:
                self.report_data['recommendations'].append(
                    "DAST scan found security issues. Review web application security."
                )
                
        except FileNotFoundError:
            print(f"Warning: ZAP results file not found: {file_path}")
        except Exception as e:
            print(f"Error parsing ZAP results: {e}")

    def calculate_overall_score(self):
        """Calculate overall security score"""
        total_critical = (self.report_data['sast']['critical'] + 
                         self.report_data['deps']['critical'] + 
                         self.report_data['containers']['critical'] + 
                         self.report_data['dast']['critical'])
        
        total_high = (self.report_data['sast']['high'] + 
                     self.report_data['deps']['high'] + 
                     self.report_data['containers']['high'] + 
                     self.report_data['dast']['high'])
        
        total_medium = (self.report_data['sast']['medium'] + 
                       self.report_data['deps']['medium'] + 
                       self.report_data['containers']['medium'] + 
                       self.report_data['dast']['medium'])
        
        # Scoring algorithm: Start with 100, deduct points for issues
        score = 100
        score -= (total_critical * 20)  # Critical issues: -20 points each
        score -= (total_high * 10)      # High issues: -10 points each
        score -= (total_medium * 5)     # Medium issues: -5 points each
        
        self.report_data['overall_score'] = max(0, score)

    def generate_html_report(self, output_file):
        """Generate HTML security report"""
        html_template = """
<!DOCTYPE html>
<html>
<head>
    <title>CloudMart Security Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { background: #2c3e50; color: white; padding: 20px; border-radius: 5px; }
        .score { font-size: 48px; font-weight: bold; text-align: center; margin: 20px 0; }
        .score.good { color: #27ae60; }
        .score.warning { color: #f39c12; }
        .score.danger { color: #e74c3c; }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        .status-pass { color: #27ae60; font-weight: bold; }
        .status-fail { color: #e74c3c; font-weight: bold; }
        .metrics { display: flex; justify-content: space-around; margin: 10px 0; }
        .metric { text-align: center; }
        .metric-value { font-size: 24px; font-weight: bold; }
        .recommendations { background: #f8f9fa; padding: 15px; border-radius: 5px; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="header">
        <h1>CloudMart Security Assessment Report</h1>
        <p>Generated on: {scan_date}</p>
        <p>Project Version: {version}</p>
    </div>
    
    <div class="score {score_class}">
        Security Score: {overall_score}/100
    </div>
    
    <div class="section">
        <h2>Security Scan Summary</h2>
        <table>
            <tr>
                <th>Scan Type</th>
                <th>Status</th>
                <th>Critical</th>
                <th>High</th>
                <th>Medium</th>
                <th>Low</th>
            </tr>
            <tr>
                <td>Static Analysis (SAST)</td>
                <td class="status-{sast_status_class}">{sast_status}</td>
                <td>{sast_critical}</td>
                <td>{sast_high}</td>
                <td>{sast_medium}</td>
                <td>{sast_low}</td>
            </tr>
            <tr>
                <td>Dependency Scan</td>
                <td class="status-{deps_status_class}">{deps_status}</td>
                <td>{deps_critical}</td>
                <td>{deps_high}</td>
                <td>{deps_medium}</td>
                <td>{deps_low}</td>
            </tr>
            <tr>
                <td>Container Security</td>
                <td class="status-{containers_status_class}">{containers_status}</td>
                <td>{containers_critical}</td>
                <td>{containers_high}</td>
                <td>{containers_medium}</td>
                <td>{containers_low}</td>
            </tr>
            <tr>
                <td>Dynamic Analysis (DAST)</td>
                <td class="status-{dast_status_class}">{dast_status}</td>
                <td>{dast_critical}</td>
                <td>{dast_high}</td>
                <td>{dast_medium}</td>
                <td>{dast_low}</td>
            </tr>
        </table>
    </div>
    
    <div class="section">
        <h2>Security Recommendations</h2>
        <div class="recommendations">
            {recommendations_html}
        </div>
    </div>
    
    <div class="section">
        <h2>Compliance Status</h2>
        <p>This report covers security assessments aligned with:</p>
        <ul>
            <li>OWASP Top 10 2021</li>
            <li>NIST Cybersecurity Framework</li>
            <li>CIS Controls</li>
            <li>SOC 2 Type II</li>
        </ul>
    </div>
</body>
</html>
        """
        
        # Determine score class
        score_class = "good" if self.report_data['overall_score'] >= 80 else "warning" if self.report_data['overall_score'] >= 60 else "danger"
        
        # Format recommendations
        recommendations_html = "<ul>"
        for rec in self.report_data['recommendations']:
            recommendations_html += f"<li>{rec}</li>"
        if not self.report_data['recommendations']:
            recommendations_html += "<li>No critical security issues found. Continue monitoring.</li>"
        recommendations_html += "</ul>"
        
        # Format HTML
        html_content = html_template.format(
            scan_date=self.report_data['scan_date'],
            version=self.report_data['version'],
            overall_score=self.report_data['overall_score'],
            score_class=score_class,
            sast_status=self.report_data['sast']['status'],
            sast_status_class=self.report_data['sast']['status'].lower(),
            sast_critical=self.report_data['sast']['critical'],
            sast_high=self.report_data['sast']['high'],
            sast_medium=self.report_data['sast']['medium'],
            sast_low=self.report_data['sast']['low'],
            deps_status=self.report_data['deps']['status'],
            deps_status_class=self.report_data['deps']['status'].lower(),
            deps_critical=self.report_data['deps']['critical'],
            deps_high=self.report_data['deps']['high'],
            deps_medium=self.report_data['deps']['medium'],
            deps_low=self.report_data['deps']['low'],
            containers_status=self.report_data['containers']['status'],
            containers_status_class=self.report_data['containers']['status'].lower(),
            containers_critical=self.report_data['containers']['critical'],
            containers_high=self.report_data['containers']['high'],
            containers_medium=self.report_data['containers']['medium'],
            containers_low=self.report_data['containers']['low'],
            dast_status=self.report_data['dast']['status'],
            dast_status_class=self.report_data['dast']['status'].lower(),
            dast_critical=self.report_data['dast']['critical'],
            dast_high=self.report_data['dast']['high'],
            dast_medium=self.report_data['dast']['medium'],
            dast_low=self.report_data['dast']['low'],
            recommendations_html=recommendations_html
        )
        
        with open(output_file, 'w') as f:
            f.write(html_content)

    def generate_json_report(self, output_file):
        """Generate JSON security report"""
        with open(output_file, 'w') as f:
            json.dump(self.report_data, f, indent=2)

def main():
    parser = argparse.ArgumentParser(description='Generate CloudMart Security Report')
    parser.add_argument('--output', default='security-dashboard', help='Output file prefix')
    parser.add_argument('--format', default='html,json', help='Output formats (html,json,pdf)')
    
    args = parser.parse_args()
    
    generator = SecurityReportGenerator()
    
    # Parse available security scan results
    generator.parse_trivy_results('trivy-frontend-results.sarif')
    generator.parse_trivy_results('trivy-backend-results.sarif')
    generator.parse_semgrep_results('semgrep-results.sarif')
    generator.parse_dependency_check_results('dependency-check-report.json')
    generator.parse_zap_results('zap-results.json')
    
    # Calculate overall score
    generator.calculate_overall_score()
    
    # Generate reports in requested formats
    formats = args.format.split(',')
    
    if 'html' in formats:
        generator.generate_html_report(f'{args.output}.html')
        print(f"HTML report generated: {args.output}.html")
    
    if 'json' in formats:
        generator.generate_json_report(f'{args.output}.json')
        print(f"JSON report generated: {args.output}.json")
    
    # Exit with appropriate code based on security score
    if generator.report_data['overall_score'] < 70:
        print(f"Security score ({generator.report_data['overall_score']}) below threshold. Review required.")
        sys.exit(1)
    else:
        print(f"Security assessment passed with score: {generator.report_data['overall_score']}")
        sys.exit(0)

if __name__ == '__main__':
    main()
