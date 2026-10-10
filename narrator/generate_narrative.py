import json
import os
import sys

def generate_scr_narrative_offline(findings: dict) -> dict:
    """Fallback fully deterministic function to format SCR narrative without API/Network."""
    narrative = f"""
Situation
Total raw revenue reported was ₹{findings['raw_total_revenue_inr']:,.2f}. After a rigorous data cleansing process, we identified a system anomaly leading to double-submitted orders. Removing these duplicates created a reconciliation delta of ₹{findings['duplicate_reconciliation_delta_inr']:,.2f}, resulting in a verified, cleaned total revenue of ₹{findings['cleaned_total_revenue_inr']:,.2f}. Furthermore, removing anomalous bulk orders (quantity outliers) shifted our understanding of demand, revealing that March was our true peak month driving ₹{findings['true_peak_month']['revenue_inr']:,.2f} in revenue, correcting the inflated perspective that January was leading.

Complication
The core threat to our operating margin lies in return rates, which are highly skewed by payment method. Analysis proves that Cash on Delivery (COD) carries a massive return rate of {findings['return_rate_by_payment']['COD']}%, drastically outperforming CARD ({findings['return_rate_by_payment']['CARD']}%) and UPI ({findings['return_rate_by_payment']['UPI']}%). The complication compounds when geolocated: our highest-risk segment is Tier-2 cities utilizing COD, which spikes to a staggering {findings['highest_risk_segment']['return_rate_pct']}% return rate.

Resolution
To protect margins, leadership must take immediate action on Tier-2 COD dependencies. We recommend implementing strict verification steps or nominal convenience fees for COD orders targeting Tier-2 cities to suppress the {findings['highest_risk_segment']['return_rate_pct']}% return leakage. Marketing should pivot to heavily incentivize prepaid methods like UPI and CARD, focusing peak promotion drives to mimic the genuine organic success seen in March (₹{findings['true_peak_month']['revenue_inr']:,.2f}).
"""
    return {
        "status": "success",
        "narrative": narrative.strip(),
        "tokens": {"prompt": 0, "completion": 0, "total": 0}
    }

def generate_scr_narrative(findings: dict) -> dict:
    """Online GenAI API function using google-genai library."""
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("No GEMINI_API_KEY found in environment. Defaulting to OFFLINE fallback path.")
        return generate_scr_narrative_offline(findings)

    try:
        from google import genai
        from google.genai import types
        
        client = genai.Client(http_options={'timeout': 15000}) 

        sys_prompt = (
            "You are a senior data analyst writing for Mamaearth's regional ops and finance heads. "
            "Write a narrative structured EXACTLY with these three labeled sections:\n"
            "1. Situation\n2. Complication\n3. Resolution\n\n"
            "Constraint: Every single number in the output must come strictly from the supplied findings JSON. "
            "Do not invent statistics. Ensure exact decimals are maintained."
        )

        user_content = f"Please draft the SCR report based on these verified findings:\n{json.dumps(findings, indent=2)}"

        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=user_content,
            config=types.GenerateContentConfig(
                system_instruction=sys_prompt,
                temperature=0.0,
                max_output_tokens=400 
            )
        )
        
        return {
            "status": "success",
            "narrative": response.text,
            "tokens": {
                "prompt": response.usage_metadata.prompt_token_count,
                "completion": response.usage_metadata.candidates_token_count
            }
        }
    except Exception as e:
        print(f"API Error encountered: {str(e)}. Defaulting to OFFLINE fallback path.")
        return generate_scr_narrative_offline(findings)

def run_numeric_checklist(narrative_text: str):
    """Task 5: Numeric accuracy checklist."""
    print("\n--- Numeric Accuracy Checklist ---")
    
    normalized_text = narrative_text.replace(",", "")
    
    check_1 = "97358.3" in normalized_text
    print(f"1. Cleaned revenue (97358.30) present: {'PASS' if check_1 else 'FAIL'}")
    
    check_2 = "44.4" in normalized_text
    print(f"2. COD return rate (44.4) present: {'PASS' if check_2 else 'FAIL'}")
    
    check_3 = "54.5" in normalized_text
    print(f"3. Tier-2 + COD return rate (54.5) present: {'PASS' if check_3 else 'FAIL'}")
    
    check_4 = "2501.9" in normalized_text
    print(f"4. Duplicate delta (2501.90) present: {'PASS' if check_4 else 'FAIL'}")
    
    check_5 = "March" in narrative_text and "20318.9" in normalized_text
    print(f"5. True peak month (March + 20318.90) present: {'PASS' if check_5 else 'FAIL'}")

if __name__ == "__main__":
    findings_path = 'narrator/findings.json'
    
    if not os.path.exists(findings_path):
        print("Error: findings.json not found. Run analysis/clean_and_eda.py first.")
        sys.exit(1)
        
    with open(findings_path, 'r') as f:
        findings = json.load(f)
        
    result = generate_scr_narrative(findings)
    print("\n=== FINAL NARRATIVE REPORT ===\n")
    print(result['narrative'])
    print("\n==============================\n")
    
    run_numeric_checklist(result['narrative'])
    
    # Save sample output for grading
    with open('narrator/sample_output.txt', 'w') as f:
        f.write(result['narrative'])
