import json
import glob
import re

from robot.api.deco import keyword

@keyword('Get top performer')
def top_performer(iotype, where, json_dir, field):
    d = list()
    for json_file in glob.glob(json_dir + \
            '/{}_*_*_1_{}.json'.format(iotype, where)):
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

    d = sorted(d, key=lambda k: int(k[field]), reverse=True)
    # output to json_dir/preliminaries.txt
    with open(json_dir + '/' + iotype + '_preliminaries.txt', 'w') as f:
        f.write("{:^20}{:>8}{:>12}{:>14}{:>14}{:>14}\n"\
                .format("NAME", "IOPS", "BW(kB/s)", "min_lat(us)",
                "max_lat(us)", "mean_lat(us)"))
        for job in d:
            f.write("{:<20}{:>8,}{:>12,}{:>14,}{:>14,}{:>14,}\n"\
                    .format(job['jobname'], job['iops'], job['bw'],
                        job['lat_min'], job['lat_max'], job['lat_mean']))
    
    # <iotype>-<iodepth>-<bs>-<thread> e.g. read-128-4m-1
    m = re.match(r'\w+-(\d+)-(\w+)-\d+', d[0]['jobname'])
    return [m.group(1), m.group(2)]

if __name__ == '__main__':
    l = top_performer('read', 'compute-006',
            'output/psnm/ceph-diskio-in-compute-006', 'bw')

    print(l)
