import json
import glob
import re
import pygal

from robot.api.deco import keyword

@keyword('Analyze data and create graph')
def create_graph(iotype, iodepth, bs, where, json_dir, sort_field):
    d = list()
    for json_file in glob.glob(json_dir + \
            '/{}_{}_{}_*_{}.json'.format(iotype, iodepth, bs, where)):
        with open(json_file, 'r') as f:
            data = json.load(f)

        for job in data['jobs']:
            # get jobname
            s_jobname = job['jobname']
            if "write" in iotype:
                s_type = 'write'
            elif "read" in iotype:
                s_type = 'read'
            bw = job[s_type]['bw']
            iops = int(job[s_type]['iops'])
            lat_us_min = int(job[s_type]['lat_ns']['min']/1000)
            lat_us_max = int(job[s_type]['lat_ns']['max']/1000)
            lat_us_mean = int(job[s_type]['lat_ns']['mean']/1000)

            d.append({
                'jobname': s_jobname,
                'iotype': iotype,
                'bw': bw,
                'iops': iops,
                'lat_min': lat_us_min,
                'lat_max': lat_us_max,
                'lat_mean': lat_us_mean
            })

    d = sorted(d, key=lambda k: int(k[sort_field]), reverse=True)
    # output to json_dir/finals.txt
    with open(json_dir + '/' + iotype + '_finals.txt', 'w') as f:
        f.write("{:^20}{:>8}{:>12}{:>14}{:>14}{:>14}\n"\
                .format("NAME", "IOPS", "BW(kB/s)", "min_lat(us)",
                "max_lat(us)", "mean_lat(us)"))
        for job in d:
            f.write("{:<20}{:>8,}{:>12,}{:>14,}{:>14,}{:>14,}\n"\
                    .format(job['jobname'], job['iops'], job['bw'],
                        job['lat_min'], job['lat_max'], job['lat_mean']))

    # Create a svg/png graph.
    g = pygal.Bar(logarithmic=True)
    g.title = '{} {} block size - Max. {} Test'.format(
                iotype.capitalize(), bs.upper(), sort_field.upper())
    g.x_labels = map(str, [x['jobname'] for x in d])
    if sort_field == 'bw':
        s_y_label = 'BW(kB/s)'
    elif sort_field == 'iops':
        s_y_label = 'IOPS'

    g.add(s_y_label, [x['bw'] for x in d],
            formatter=lambda x: '{:,}'.format(x))
    g.add('min_lat(us)', [x['lat_min'] for x in d],
        formatter=lambda x: '{:,}'.format(x))
    g.add('mean_lat(us)', [x['lat_mean'] for x in d],
            formatter=lambda x: '{:,}'.format(x))
    g.add('max_lat(us)', [x['lat_max'] for x in d],
            formatter=lambda x: '{:,}'.format(x))
    g.render_to_file(json_dir + '/' + iotype + '.svg')

if __name__ == '__main__':
    create_graph('read', 256, '4m', 'compute-006',
            'output/psnm/ceph-diskio-in-compute-006', 'bw')

#    print("{:^15}{:>6}{:>12}{:>14}{:>14}{:>14}"\
#            .format("NAME", "IOPS", "BW(kB/s)", "min_lat(us)",
#            "max_lat(us)", "mean_lat(us)"))
#    
#    for job in d:
#        print("{:<15}{:>6,}{:>12,}{:>14,}{:>14,}{:>14,}"\
#                .format(job['jobname'], job['iops'], job['bw'], job['lat_min'],
#                    job['lat_max'], job['lat_mean']))
