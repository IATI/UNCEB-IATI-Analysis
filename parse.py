import os
from lxml import etree
import csv

basic_xpaths = [
    'reporting-org',
    'iati-identifier',
    'participating-org',
    'title',
    'description',
    'activity-status',
    'sector|transaction/sector',
    'recipient-country|recipient-region|transaction/recipient-country|transaction/recipient-region'
]

if __name__ == '__main__':
    rootdir = 'data'

    header = [
        "iati_identifier",
        "reporting_org_ref",
        "start_date",
        "reporting_org",
        "un_function_code",
        "geographic_location",
        "grant_financing_instruments",
        "sdgs_sector_tag_result",
        "contributor",
        "vocab_1_sector_code",
        "gender_marker",
        "basic_activity_data",
        "finance_type",
        "incoming_funds",
        "budget",
        "disbursements_or_expenditures"
    ]
    output = list()
    for subdir, dirs, files in os.walk(rootdir):
        for filename in files:
            filepath = os.path.join(subdir, filename)
            print(subdir, filename)
            try:
                context = etree.iterparse(filepath, tag='iati-activity', huge_tree=True)
                for _, activity in context:
                    identifiers = activity.xpath("iati-identifier/text()")
                    if identifiers:
                        output_row = list()
                        identifier = identifiers[0].strip()
                        output_row.append(identifier)

                        output_row.append(os.path.split(subdir)[1])

                        planned_start = activity.xpath("activity-date[@type='1']/@iso-date")
                        actual_start = activity.xpath("activity-date[@type='2']/@iso-date")
                        try:
                            start_date = actual_start[0] if len(actual_start) > 0 else planned_start[0]
                        except:
                            start_date = activity.xpath("activity-date/@iso-date")[0]
                        output_row.append(start_date)

                        reporting_org = len(activity.xpath("reporting-org")) > 0
                        output_row.append(reporting_org)

                        un_function_code = len(activity.xpath("sector[@vocabulary='12']|transaction/sector[@vocabulary='12']")) > 0
                        output_row.append(un_function_code)

                        geographic_location = len(activity.xpath("recipient-country|recipient-region|transaction/recipient-country|transaction/recipient-region")) > 0
                        output_row.append(geographic_location)
                        
                        grant_financing_instruments = len(activity.xpath("default-aid-type|transaction/aid-type")) > 0
                        output_row.append(grant_financing_instruments)

                        sdgs_sector_tag_result = len(activity.xpath(
                            "sector[@vocabulary='7' or @vocabulary='8' or @vocabulary='9'] | transaction[sector[@vocabulary='7' or @vocabulary='8' or @vocabulary='9']] | tag[@vocabulary='2' or @vocabulary='3'] | result[indicator[reference[@vocabulary='9']]]"
                        )) > 0
                        output_row.append(sdgs_sector_tag_result)

                        contributor = len(activity.xpath("participating-org[@role='1']")) > 0
                        output_row.append(contributor)

                        vocab_1_sector_code = len(activity.xpath("sector[@vocabulary='1' or not(@vocabulary)]|transaction/sector[@vocabulary='1' or not(@vocabulary)]")) > 0
                        output_row.append(vocab_1_sector_code)

                        gender_marker = len(activity.xpath("policy-marker[(@vocabulary='1' or not(@vocabulary)) and @code='1']")) > 0
                        output_row.append(gender_marker)

                        basic_activity_data = True
                        for basic_xpath in basic_xpaths:
                            basic_activity_data = basic_activity_data and (len(activity.xpath(basic_xpath)) > 0)
                        output_row.append(basic_activity_data)
                        
                        finance_type = len(activity.xpath("default-finance-type|transaction/finance-type")) > 0
                        output_row.append(finance_type)

                        incoming_funds = len(activity.xpath("transaction/receiver-org")) > 0
                        output_row.append(incoming_funds)

                        budget = len(activity.xpath("budget")) > 0
                        output_row.append(budget)

                        disbursements_or_expenditures = len(activity.xpath("transaction/transaction-type[@code='3' or @code='4']")) > 0
                        output_row.append(disbursements_or_expenditures)

                        output.append(output_row)

                    # Free memory
                    activity.clear()
                    for ancestor in activity.xpath('ancestor-or-self::*'):
                        while ancestor.getprevious() is not None:
                            try:
                                del ancestor.getparent()[0]
                            except TypeError:
                                break

                del context

            except etree.XMLSyntaxError:
                continue

    with open('unceb_data.csv', 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(output)
