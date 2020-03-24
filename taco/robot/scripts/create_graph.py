import json

# d = {
#       'vm': 
#         [
#           {'jobname':,'iotype':,'bw':,'iops':,'slat_us_mean':,'clat_us_mean'}
#           ,...
#         ],
#       ,'node':
#         [
#           {'jobname':,'iotype':,'bw':,'iops':,'slat_us_mean':,'clat_us_mean'}
#           ,...
#         ],
# }
# d['vm'][n]['bw']

# VM
d = dict()
d['vm'] = list()

with open("../fio/perf-target.json", "r") as f:
    data = json.load(f)

for job in data['jobs']:
    # get jobname
    s_jobname = job['jobname']
    s_iotype = job['job options']['rw']
    if "write" in s_jobname:
        s_type = 'write'
    elif "read" in s_jobname:
        s_type = 'read'
    bw = job[s_type]['bw']
    iops = int(job[s_type]['iops'])
    slat_us_mean = int(job[s_type]['slat_ns']['mean']/1000)
    clat_us_mean = int(job[s_type]['clat_ns']['mean']/1000)
    d['vm'].append({
        'jobname': s_jobname
        , 'iotype': s_iotype
        , 'bw': bw
        , 'iops': iops
        , 'slat_mean': slat_us_mean
        , 'clat_mean': clat_us_mean
    })

# Node
d['node'] = list()

with open("../fio/control-001.json", "r") as f:
    data = json.load(f)

for job in data['jobs']:
    # get jobname
    s_jobname = job['jobname']
    s_iotype = job['job options']['rw']
    if "write" in s_jobname:
        s_type = 'write'
    elif "read" in s_jobname:
        s_type = 'read'
    bw = job[s_type]['bw']
    iops = int(job[s_type]['iops'])
    slat_us_mean = int(job[s_type]['slat_ns']['mean']/1000)
    clat_us_mean = int(job[s_type]['clat_ns']['mean']/1000)
    d['node'].append({
        'jobname': s_jobname
        , 'iotype': s_iotype
        , 'bw': bw
        , 'iops': iops
        , 'slat_mean': slat_us_mean
        , 'clat_mean': clat_us_mean
    })


print("{:^15}{:^15}{:^15}".format("Item", "VM", "Node"))
for i, job in enumerate(d['vm']):
    print('[' + job['jobname'] + ']')
    print("{:<15}{:^15,}{:^15,}"\
            .format("bw(kB/s)", job['bw'], d['node'][i]['bw']))
    print("{:<15}{:^15,}{:^15,}"\
            .format("iops", job['iops'], d['node'][i]['iops']))
    #print("{:<15}{:^15,}{:^15,}"\
    #        .format("slat(us)", job['slat_mean'], d['node'][i]['slat_mean']))
    print("{:<15}{:^15,}{:^15,}"\
            .format("clat(us)", job['clat_mean'], d['node'][i]['clat_mean']))

import pygal

# create bandwidth graph
g = pygal.Bar(width=800)
g.title = 'Bandwidth (KB/s)'
g.x_labels = map(str, [x['jobname'] for x in d['vm']])
g.add('VM', [x['bw'] for x in d['vm']])
g.add('Node', [x['bw'] for x in d['node']])
g.render_to_file('../output/bw.svg')

# create iops graph
g = pygal.Bar(width=800)
g.title = 'IOPS'
g.x_labels = map(str, [x['jobname'] for x in d['vm']])
g.add('VM', [x['iops'] for x in d['vm']])
g.add('Node', [x['iops'] for x in d['node']])
g.render_to_file('../output/iops.svg')

# create clat graph
g = pygal.Bar(width=800)
g.title = 'Avg. Complete Latency (us)'
g.x_labels = map(str, [x['jobname'] for x in d['vm']])
g.add('VM', [x['clat_mean'] for x in d['vm']])
g.add('Node', [x['clat_mean'] for x in d['node']])
g.render_to_file('../output/clat_mean.svg')
