import json
import glob
import re

from robot.api.deco import keyword

@keyword('Sum fio data')
def sum_fio_data(iotype, iodepth, bs, num_procs, json_dir, sort_field):
    d = list()
    for json_file in glob.glob(json_dir +  \
            '/{}_{}_{}_{}_*.json'.format(iotype, iodepth, bs, num_procs)):
        # get node name
        m = re.match(r'.*_([^_]+).json', json_file)
        s_nodename = m.group(1)

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
                'nodename': s_nodename,
                'jobname': s_jobname,
                'iotype': iotype,
                'bw': bw,
                'iops': iops,
                'lat_min': lat_us_min,
                'lat_max': lat_us_max,
                'lat_mean': lat_us_mean
            })

    d = sorted(d, key=lambda k: int(k[sort_field]), reverse=True)
    # output to json_dir/preliminaries.txt
    s_output = json_dir + '/{}_{}_{}_{}.txt'.format(iotype, iodepth, bs,
            num_procs)
    s_header_format = "{:^12}{:>12}{:>12}{:>14}{:>14}{:>14}\n"
    s_data_format = "{:^12}{:>12,}{:>12,}{:>14,}{:>14,}{:>14,}\n"
    with open(s_output, 'w') as f:
        f.write(s_header_format\
                .format("NODE NAME", "IOPS", "BW(kB/s)", "mean_lat(us)",
                "max_lat(us)", "min_lat(us)"))
        for job in d:
            f.write(s_data_format\
                    .format(job['nodename'], job['iops'], job['bw'],
                        job['lat_mean'], job['lat_max'], job['lat_min']))
        # Sum iops and bw and avg. lat_mean
        sum_iops = sum(x['iops'] for x in d)
        sum_bw = sum(x['bw'] for x in d)
        avg_lat_mean = float(sum(x['lat_mean'] for x in d)/len(d))
        max_lat_max = max(x['lat_max'] for x in d)
        min_lat_min = min(x['lat_min'] for x in d)
        f.write(s_data_format\
                .format("SUM", sum_iops, sum_bw, avg_lat_mean, max_lat_max,
                    min_lat_min))
    
    # <iotype>-<iodepth>-<bs>-<thread> e.g. read-128-4m-1
    m = re.match(r'\w+-(\d+)-(\w+)-\d+', d[0]['jobname'])
    return [sum_iops, sum_bw, avg_lat_mean, max_lat_max, min_lat_min]

if __name__ == '__main__':
    l = sum_fio_data('randwrite', 32, '4k', 1,
            'output/psnm/ceph-randwrite', 'iops')

    print(l)
