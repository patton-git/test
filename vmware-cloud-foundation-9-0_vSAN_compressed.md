VMware Cloud Foundation 9.0

# **vSAN**


Use **vSAN** as a VI administrator or storage administrator to enhance storage performance by aggregating local storage
into a single shared pool across all hosts in a vSAN cluster.


**In This Chapter**

- Designing vSAN Network

- Planning and Configuring vSAN

- Administering VMware vSAN

- Monitoring and Troubleshooting vSAN


**Getting to Know VCF**

To apply this documentation, you must be acquainted with the VCF Product Overview, VCF Design, and VCF Release
Notes.


**SDKs, APIs, and CLI for VCF Administration**

You can build, operate, and manage your VCF private cloud by using the VCF SDK and APIs, and VCF PowerCLI. See
Administration SDKs, APIs, and CLI.
## **Designing vSAN Network**

The _Designing vSAN Network_ guide describes network requirements, network design, and configuration practices for
deploying a highly available and scalable VMware [®] vSAN [™] cluster.

vSAN is a distributed storage solution. As with any distributed solution, the network is an important component of the
design. For best results, you must adhere to the guidance provided in this document as improper networking hardware
and designs can lead to unfavorable results.

At VMware, we value inclusion. To foster this principle within our customer, partner, and internal community, we create
content using inclusive language.


**Intended Audience**

This guide is intended for anyone who is designing, deploying, and managing a vSAN cluster. The information in this
guide is written for experienced network administrators who are familiar with network design and configuration, virtual
machine management, and virtual data center operations. This guide also assumes familiarity with VMware vSphere,
including VMware ESXi, vCenter, and the vSphere Client.

- For more information about creating vSAN clusters, see the Planning and Configuring vSAN guide.

- For more information about vSAN features and how to configure a vSAN cluster, see the Administering VMware vSAN
guide.

- For more information about monitoring a vSAN cluster and fixing problems, see the Monitoring and Troubleshooting
vSAN guide.
### **What is vSAN Network Design**

You can use vSAN to provision shared storage within vSphere. vSAN aggregates local or direct-attached storage devices
of a host cluster and creates a single storage pool shared across all hosts in the vSAN cluster.


VMware by Broadcom 1598


VMware Cloud Foundation 9.0


vSAN is a distributed and shared storage solution that depends on a highly available, properly configured network
for vSAN storage traffic. A fast and resilient network is crucial to a successful vSAN deployment. This guide provides
recommendations on how to design and configure a vSAN network.

vSAN has a distributed architecture that relies on a fast, scalable, and resilient network. All host nodes within a vSAN
cluster communicate over the IP network. All hosts in the cluster must maintain IP unicast connectivity, so they can
communicate over a Layer 2 or Layer 3 network. For more information on the unicast communication, see Using Unicast
in vSAN Network.


**vSAN Networking Terms and Definitions**

vSAN introduces specific terms and definitions that are important to understand. Before you get start designing your vSAN
network, review the key vSAN networking terms and definitions.

|Terms|Definitions|
|---|---|
|CMMDS|The Cluster Monitoring, Membership, and Directory Service<br>(CMMDS) is responsible for the recovery and maintenance of a<br>cluster of networked node members. It manages the inventory of<br>items such as host nodes, devices, and networks. It also stores<br>metadata information, such as policies and RAID configuration for<br>vSAN objects.|
|DOM|The Distributed Object Manager (DOM) is responsible for creating<br>the components and distributing them across the cluster. After a<br>DOM object is created, one of the nodes (host) is nominated as<br>the DOM owner for that object. This host handles all IOPS to that<br>DOM object by locating the respective child components across<br>the cluster and redirecting the I/O to respective components<br>over the vSAN network. DOM objects include vdisk, snapshot,<br>vmnamespace, vmswap, vmem, and so on.|
|NIC Teaming|Network Interface Card (NIC) teaming can be defined as two or<br>more network adapters (NICs) that are set up as a "team" for high<br>availability and load balancing.|
|NIOC|Network I/O Control (NIOC) determines the bandwidth that<br>different network traffic types are given on a vSphere distributed<br>switch. The bandwidth distribution is a user configurable<br>parameter. When NIOC is enabled, distributed switch traffic is<br>divided into predefined network resource pools: Fault Tolerance<br>traffic, iSCSI traffic, vMotion traffic, management traffic, vSphere<br>Replication traffic, NFS traffic, and virtual machine traffic.|
|Objects and Components|Each object is composed of a set of components, determined by<br>capabilities that are in use in the VM Storage Policy.<br>A vSAN datastore contains several object types:<br>•<br>**VM Home Namespace** - The VM Home Namespace is a<br>virtual machine home directory where all virtual machine<br>configuration files are stored. This includes files such as .vmx,<br>log files, vmdks, and snapshot delta description files.<br>•<br>**VMDK** - VMDK is a virtual machine disk or .vmdk file that<br>stores the contents of the virtual machine's hard disk drive.<br>•<br>**VM Swap Object** - VM Swap Objects are created when a<br>virtual machine is powered on.<br>•<br>**Snapshot Delta VMDKs** - Snapshot Delta VMDKs are created<br>when virtual machine snapshots are taken. This is applicable<br>only for vSAN OSA cluster.|



VMware by Broadcom 1599


VMware Cloud Foundation 9.0

|Terms|Definitions|
|---|---|
||~~•~~<br>**Memory Object** - Memory Objects are created when the<br>snapshot memory option is selected when creating or<br>suspending a virtual machine.|
|RDT|The Reliable Data Transport (RDT) protocol is used for<br>communication between hosts over the vSAN VMkernel ports. It<br>uses TCP at the transport layer and is responsible to create and<br>destroy TCP connections (sockets) on demand. It is optimized to<br>send large files.|
|SPBM|Storage Policy-Based Management (SPBM) provides a storage<br>policy framework that serves as a single unified control panel<br>across a broad range of data services and storage solutions. This<br>framework helps you to align storage with application demands of<br>your virtual machines.|
|VLAN|A VLAN enables a single physical LAN segment to be further<br>segmented so that groups of ports are isolated from one another<br>as if they were on physically different segments.|
|Witness Component|A witness is a component that contains only metadata and does<br>not contain any actual application data. It serves as a tiebreaker<br>when a decision must be made regarding the availability of the<br>surviving datastore components, after a potential failure.|


### **Understanding vSAN Networking**

A vSAN network facilitates the communication between cluster hosts, and must be fast, resilient, and scalable.

vSAN uses the network to communicate between the ESXi hosts and for virtual machine disk I/O.

Virtual machines (VMs) on vSAN datastores are made up of a set of objects, and each object can be made up of one or
more components. These components are distributed across multiple hosts for resilience to drive and host failures. vSAN
maintains and updates these components using the vSAN network.

The following diagram provides a high-level overview of the vSAN network:


VMware by Broadcom 1600


VMware Cloud Foundation 9.0









**vSAN Network Characteristics**

vSAN is network-dependent. Understanding and configuring the right vSAN network settings is critical to avoiding
performance and stability issues.

A reliable and robust vSAN network has the following characteristics:

**vSAN Network Traffic**

vSAN network traffic is primarily made up of cluster, metadata, and storage replication traffic. A VM can access its storage
resources from any host within a vSAN cluster. It is not necessary for that data to be locally available, thus allowing a VM
to access its data on another node.

**Unicast**

vSAN uses unicast for communication. Unicast traffic is a one-to-one transmission of IP packets from one point in the
network to another point. Unicast transmits the heartbeat sent from the primary host to all other hosts each second. This
ensures that the hosts are active and indicates the participation of hosts in the vSAN cluster. You can design a simple
unicast network for vSAN. For more information on the unicast communication, see Using Unicast in vSAN Network.

**Note:**

If possible, always use the latest version of vSAN.

**Layer 2 and Layer 3 Network**

All hosts in the vSAN cluster must be connected through a Layer 2 (L2) or Layer 3 (L3) network.

**VMkernel Network**


VMware by Broadcom 1601


VMware Cloud Foundation 9.0


Each ESXi host in a vSAN cluster must have a network adapter for vSAN communication. All the intra cluster
communication happens through the vSAN VMkernel port.

**VMkernel Interface**

Each ESXi host in a vSAN cluster must have a VMkernel interface used for vSAN traffic to handle data replication, I/O
traffic, and cluster health monitoring.

**Virtual Switch**

vSAN supports the following types of virtual switches:

- The Standard Virtual Switch provides connectivity from VMs and VMkernel ports to external networks. This switch is
local to each ESXi host.

- A vSphere Distributed Switch provides central control of the virtual switch administration across multiple ESXi hosts. A
distributed switch also provides networking features such as Network I/O Control (NIOC) that can help you set Quality
of Service (QoS) levels on vSphere or virtual network. vSAN includes vSphere Distributed Switch irrespective of the
vCenter version.

**Network Interfaces**

vSAN can have dedicated physical network interfaces to secure vSAN storage traffic and to provide bandwidth and
resources. vSAN traffic can share physical network adapters with other system traffic types, such as vSphere vMotion
traffic, vSphere HA traffic, and virtual machine traffic. To guarantee the amount of bandwidth required for vSAN, configure
Network I/O control on the distributed switch.

**Bandwidth**

In vSAN environments that share physical resources with other traffic, use Network I/O Control to allocate bandwidth
among traffic types. Assigning shares to vSAN traffic ensures that it receives sufficient bandwidth during network
contention. This prioritizes vSAN traffic and prevents other traffic types from affecting its performance when the physical
NIC is saturated.

Avoid using reservations or limits in vSAN environments. Reservations can leave unused bandwidth inaccessible to VMs,
while limits restrict traffic even when additional bandwidth is available.

vSAN recommends the usage of shares to allocate bandwidth for vSAN traffic. This offers the most balanced and efficient
use of shared physical NICs.

[For information about using Network I/O Control to configure bandwidth allocation for vSAN traffic, see the vSphere](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/vsphere-networking.html)
[Networking guide.](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/vsphere-networking.html)


**Using Unicast in vSAN Network**


Unicast traffic refers to a one-to-one transmission from one point in the network to another. vSAN uses unicast to simplify
network design and deployment.

All ESX hosts use the unicast traffic, and the vCenter becomes the source for the cluster membership. The vSAN nodes
are automatically updated with the latest host membership list that vCenter provides. vSAN communicates using unicast
[for CMMDS updates. For more information on CMMDS updates, see Broadcom knowledge base article 385769.](https://knowledge.broadcom.com/external/article/385769/vsan-how-to-find-the-cmmds-and-stats-mas.html)


**DHCP Support on Unicast Network**
vCenter deployed on a vSAN cluster can use IP addresses from Dynamic Host Configuration Protocol (DHCP) without
reservations.

You can use DHCP without reservations as the assigned IP addresses are tied to the MAC addresses of VMkernel ports.


VMware by Broadcom 1602


VMware Cloud Foundation 9.0


**IPv6 Support on Unicast Network**
vSAN supports IPv6 with unicast communications.

With IPv6, the link-local address is automatically configured on any interface using the link-local prefix. By default, vSAN
does not add the link local address of a node to other neighboring cluster nodes. As a result, vSAN does not support IPv6
link local addresses for unicast communications.


**Query Unicast with ESXCLI**
You can run ESXCLI commands to determine the unicast configuration.

View the Communication Modes
Using `esxcli vsan cluster get` command, you can view the CMMDS mode of the vSAN cluster node.

Run the `esxcli vsan cluster get` command.


```
Cluster Information
Enabled: true
Current Local Time: 2025-05-08T09:08:05Z
Local Node UUID: 6813878b-163d-3a33-cc63-0050569c4bac
Local Node Type: NORMAL
Local Node State: MASTER
Local Node Health State: HEALTHY

```

```
Sub-Cluster Master UUID: 6813878b-163d-3a33-cc63-0050569c4bac
Sub-Cluster Backup UUID: 6813878b-f828-8805-6e39-0050569c8100
Sub-Cluster UUID: 52fafd2f-885a-912b-123d-29320735129c
Sub-Cluster Membership Entry Revision: 17
Sub-Cluster Member Count: 16
Sub-Cluster Member UUIDs: 6813878b-163d-3a33-cc63-0050569c4bac, 68138792-d6cb-49f1-24d4-0050569c8d7d,
6813878c-1ae0-1798-21ba-0050569c8c1a, 68138791-7d9b-c043-b0e7-0050569c74f8, 6813878b-5ec9b6d7-70ce-0050569c37d1, 6813878b-d309-023b-2c66-0050569ccf58, 6813878c-9879-9875-2cf0-0050569c5f2f,
6813878b-d7b2-c9f1-ce14-0050569ce307, 6813878b-f828-8805-6e39-0050569c8100, 6813878c-aab3-3810-65d
c-0050569c55f1, 68138797-2924-1613-be3b-0050569cfe64, 68138793-f8bc-f72f-1e0d-0050569ce100,
68138791-58f8-8831-8403-0050569c8cfb, 6813878b-ae9c-6346-d735-0050569c73af, 68138782b02a-785a-4b5e-0050569ce4b4, 681512d1-f5d1-c10e-8b0c-0050569cf5e5
Sub-Cluster Member HostNames: sfo01-m01-r01-esx01.sfo.rainpole.io, sfo01-m01-r01-esx02.sfo.rainpole.io,
sfo01-m01-r01-esx03.sfo.rainpole.io, sfo01-m01-r01-esx04.sfo.rainpole.io, sfo01-m01-r01-esx05.sfo.rain
pole.io, sfo01-m01-r01-esx06.sfo.rainpole.io, sfo01-m01-r01-esx07.sfo.rainpole.io, sfo01-m01-r01-esx08.s
fo.rainpole.io, sfo02-m01-r01-esx08.sfo.rainpole.io, sfo02-m01-r01-esx07.sfo.rainpole.io, sfo02-m01-r01-es

```

```
 x04.sfo.rainpole.io, sfo02-m01-r01-esx06.sfo.rainpole.io, sfo02-m01-r01-esx03.sfo.rainpole.io, sfo02-m01-r01 esx02.sfo.rainpole.io, sfo02-m01-r01-esx05.sfo.rainpole.io, sfo-m01-cl01-vsw01.sfo.rainpole.io
 Sub-Cluster Membership UUID: f89b1468-4c6d-7ebf-2a19-0050569c929a
 Unicast Mode Enabled: true
 Maintenance Mode State: OFF
 Config Generation: a90bad14-6d09-4a42-b001-5137386ff625 9 2025-05-08T03:05:15.343
 Mode: REGULAR
 vSAN ESA Enabled: true
 vSAN Max Client Network Enabled: false
```

Verify the vSAN Cluster Hosts
Use the esxcli vSAN cluster unicastagent list command to list the unicast communications details



Run the `esxcli vsan cluster unicastagent list` command.


VMware by Broadcom 1603


VMware Cloud Foundation 9.0

```
NodeUuid               IsWitness Supports Unicast IP Address   Port Iface Name Cert
Thumbprint                                         SubClusterUuid
Traffic Type
------------------------------------ --------- ---------------- ------------ ----- ------------------------------------------------------------------------------------------------------------------------------------------- -----------6813878b-f828-8805-6e39-0050569c8100     0       true 10.12.13.108 12321
D8:14:DA:80:2F:0C:0E:0C:BD:40:89:24:70:3D:33:EE:62:0B:6E:7C:4F:8D:D3:06:88:46:39:DD:E7:15:9D:0F
52fafd2f-885a-912b-123d-29320735129c vsan
681512d1-f5d1-c10e-8b0c-0050569cf5e5     1       true 10.21.10.218 12321
A7:02:80:3B:64:8F:9A:AB:29:6B:54:3E:C1:76:01:3E:00:A2:DE:80:F4:78:7B:6C:E8:B9:3A:4A:77:4B:0F:38
52fafd2f-885a-912b-123d-29320735129c
6813878c-aab3-3810-65dc-0050569c55f1     0       true 10.12.13.107 12321
45:2E:E7:40:9E:0B:5D:87:18:2E:8E:C6:86:86:97:B1:B5:6E:79:57:C2:9E:21:3C:5F:4B:76:D3:3B:72:64:1B
52fafd2f-885a-912b-123d-29320735129c vsan
68138797-2924-1613-be3b-0050569cfe64     0       true 10.12.13.104 12321
ED:97:72:FA:A0:52:6E:17:61:97:8C:3D:6F:CC:CB:49:98:56:97:AA:8B:9B:BE:47:D0:4A:35:A2:0E:95:FA:6C
52fafd2f-885a-912b-123d-29320735129c vsan
68138793-f8bc-f72f-1e0d-0050569ce100     0       true 10.12.13.106 12321
86:99:32:7A:20:4A:D2:B3:B3:A9:6D:BE:60:A3:26:5B:83:EB:49:34:76:FB:7A:5B:EE:0E:54:FB:DC:AC:BE:74
52fafd2f-885a-912b-123d-29320735129c vsan
68138791-58f8-8831-8403-0050569c8cfb     0       true 10.12.13.103 12321
B2:4F:11:0E:98:07:80:45:F2:F2:06:C9:D9:89:57:FA:8D:3C:2B:E3:A5:25:5C:2B:A5:D8:5A:17:6F:87:0D:7C
52fafd2f-885a-912b-123d-29320735129c vsan
6813878b-d309-023b-2c66-0050569ccf58     0       true 10.11.13.106 12321
E2:D6:36:BE:C8:D5:A2:F0:42:41:EF:9F:4C:D2:AD:67:6C:54:4E:3A:50:B3:B3:7C:35:54:A2:B7:3F:C9:5B:11
52fafd2f-885a-912b-123d-29320735129c vsan
68138791-7d9b-c043-b0e7-0050569c74f8     0       true 10.11.13.104 12321
21:FC:6F:56:C9:26:33:6E:8E:1E:58:7D:A2:3F:3E:38:09:96:99:61:F2:7F:AB:F1:25:C9:6C:CC:0D:6D:BB:06
52fafd2f-885a-912b-123d-29320735129c vsan
6813878b-ae9c-6346-d735-0050569c73af     0       true 10.12.13.102 12321
A5:47:6C:FE:2A:9A:A9:8C:08:03:34:AD:D1:E0:A9:FA:9E:17:4F:62:1F:15:D1:ED:8B:01:D8:CE:D4:D7:01:D8
52fafd2f-885a-912b-123d-29320735129c vsan
68138782-b02a-785a-4b5e-0050569ce4b4     0       true 10.12.13.105 12321
3C:92:51:62:F5:59:A0:73:39:E5:DE:B1:A9:1F:72:1E:F7:5D:4C:48:12:76:A5:BE:9B:16:FE:05:94:2A:EA:37
52fafd2f-885a-912b-123d-29320735129c vsan
6813878c-9879-9875-2cf0-0050569c5f2f     0       true 10.11.13.107 12321
77:8E:F9:D1:21:6B:CD:3C:66:A2:4A:55:BE:78:30:00:E9:BD:96:6B:F8:6F:FB:1C:1F:5E:33:6C:DE:D3:4D:7E
52fafd2f-885a-912b-123d-29320735129c vsan
6813878c-1ae0-1798-21ba-0050569c8c1a     0       true 10.11.13.103 12321
77:24:E0:DF:64:FD:D2:B1:FD:FA:D7:5B:1B:2C:FF:12:15:99:11:CE:FB:41:84:8D:3F:57:C0:67:A1:6F:12:B3
52fafd2f-885a-912b-123d-29320735129c vsan
6813878c-8bcb-20c9-0429-0050569c2f06     0       true 10.12.13.101 12321
43:E4:88:EB:55:04:FF:BA:8F:BE:12:C5:52:AB:21:05:9B:2C:04:11:68:34:4B:E7:AC:BE:F7:07:A9:B3:B1:C9
52fafd2f-885a-912b-123d-29320735129c vsan
6813878b-5ec9-b6d7-70ce-0050569c37d1     0       true 10.11.13.105 12321
A3:FC:61:0B:C3:37:43:47:54:EA:B2:A1:9F:B4:B2:D6:A0:C0:92:F9:79:6F:FF:B8:CD:3F:48:B0:28:FC:CA:AD
52fafd2f-885a-912b-123d-29320735129c vsan
68138792-d6cb-49f1-24d4-0050569c8d7d     0       true 10.11.13.102 12321
C1:3C:C4:B1:C1:94:A6:5B:C1:17:F5:15:39:BB:C2:2D:41:2A:1E:71:B8:0F:8D:FB:DD:96:12:70:F6:82:D4:DA
52fafd2f-885a-912b-123d-29320735129c vsan

```


VMware by Broadcom 1604


VMware Cloud Foundation 9.0

```
 6813878b-d7b2-c9f1-ce14-0050569ce307     0       true 10.11.13.108 12321
 20:92:8B:1B:CE:D6:7B:5D:98:89:67:CD:D8:4B:E5:43:A5:56:F3:1A:D1:51:16:02:90:E4:50:76:02:A5:29:93
 52fafd2f-885a-912b-123d-29320735129c vsan
```

The output includes the vSAN node UUID, whether the node is a data host (0) or a witness host (1), IPv4 address/IPv6
address, UDP port, certificate thumbprint, and vSAN subcluster ID and traffic type. If troubleshooting, you can use this
output to identify the vSAN cluster nodes match to ensure what vCenter maintains.

View the vSAN Network Information
Use the `esxcli vsan network list` command to view the vSAN network information such as the VMkernel interface
that vSAN uses for communication, the unicast port (12321), and the traffic type (vSAN or witness) associated with the
vSAN interface.

Run the `esxcli vsan network list` command.


```
Interface
VmkNic Name: vmk1
IP Protocol: IP
Interface UUID: e290be58-15fe-61e5-1043-246e962c24d0
Agent Group Multicast Address: 224.2.3.4
Agent Group IPv6 Multicast Address: ff19::2:3:4
Agent Group Multicast Port: 23451
Master Group Multicast Address: 224.1.2.3

```

```
Master Group IPv6 Multicast Address: ff19::1:2:3
Master Group Multicast Port: 12345

```

```
 Host Unicast Channel Bound Port: 12321

```

```
Multicast TTL: 5
Traffic Type: vsan

```


This output also displays the vmkernal interface used for vSAN, and vSAN traffic type. While the output displays muticast,
it is no longer used for vSAN communication and can be ignored.

**Intra-Cluster Traffic**
In unicast mode, the primary node addresses all the cluster nodes as it sends the same message to all the vSAN nodes in
a cluster.

For example, if N is the number of vSAN nodes, then the primary node sends the messages N number of times. This
results in a slight increase of vSAN CMMDS traffic. You might not notice this slight increase of traffic during normal,
steady-state operations.


Intra-Cluster Traffic in a Single Rack
If all the nodes in a vSAN cluster are connected to the same top of the rack (TOR) switch, then the total increase in traffic
is only between the primary node and the switch.

If a vSAN cluster spans more than one TOR switch, you need to monitor the network traffic bandwidth and network
latency to ensure adequate resources are available to satisfy vSAN requirements. If a cluster spans many racks, multiple
TORs may be involved. A single L2 can span multiple racks or L3 can be used across multiple TORs. vSAN Fault
Domains could be considered with L3 to have a logical and physical fault domain at a rack boundary.


VMware by Broadcom 1605


VMware Cloud Foundation 9.0


Intra-Cluster Traffic in a vSAN Stretched Cluster
In a vSAN stretched cluster, the primary node is located at the preferred site.

In a vSAN stretched cluster configuration, vSAN data is synchronously replicated bidirectionally between the preferred
site and the secondary site. vSAN read I/O is local to each site. As a result write I/O bandwidth between the sites depend
on many factors such as number of vSAN nodes on each site, the aggregate physical NIC bandwidth of the combined
hosts between each site, and the number of vSAN objects that are using site to site replication. To calculate bandwidth
[requirements for vSAN OSA and vSAN ESA, see VMware vSAN Design and Sizing Guide.](https://www.vmware.com/docs/vmware-vsan-design-guide)


VMware by Broadcom 1606


VMware Cloud Foundation 9.0


With the unicast traffic, there is no change in the witness site traffic requirements.


**ESXi Traffic Types**

ESXi hosts use different network traffic types to support vSAN.

Following are the different traffic types that you need to set up for vSAN.

**Note:**

These network traffic types are not applicable to vSAN storage clusters if the VMs are not deployed on the cluster.


**Table 823: Network Traffic Types**

|Traffic Types|Description|
|---|---|
|Management network|The management network is the primary network interface that uses a VMkernel TCP/IP<br>stack to facilitate the host connectivity and management. It can also handle the system traffic<br>such as vMotion, iSCSI, Network File System (NFS), Fiber Channel over Ethernet (FCoE),<br>and fault tolerance.|
|Virtual Machine network|With virtual networking, you can network VMs and build complex networks within a single<br>ESXi host or across multiple ESXi hosts.|
|vMotion network|Traffic type that facilitates migration of VM from one host to another. Migration with vMotion<br>requires correctly configured network interfaces on source and target hosts. Ensure that the<br>vMotion network is distinct from the vSAN network.|



VMware by Broadcom 1607


VMware Cloud Foundation 9.0

|Traffic Types|Description|
|---|---|
|vSAN network|A vSAN cluster requires the VMkernel network for the exchange of data. Each ESXi host<br>in the vSAN cluster must have a VMkernel network adapter for the vSAN traffic. For more<br>information, seeManually Enabling vSAN.|



**Network Requirements for vSAN**

vSAN is a distributed storage solution that depends on the network for communication between hosts. Before deployment,
ensure that your vSAN environment has all the networking requirements.

**Physical NIC Requirements**


Network Interface Cards (NICs) used in vSAN hosts must meet certain requirements. vSAN works on 10 GbEs, 25 GbEs,
40 GbEs, 50 GbEs, and 100 GbEs networks.

Ensure your hosts meet the minimum NIC requirements:


**Table 824: Minimum NIC Requirements and Recommendations**

















vSAN HCI Cluster
(Hybrid)

vSAN HCI Cluster
(All Flash)

vSAN Stretched
Cluster


Two-Node vSAN
Cluster


vSAN Stretched
Compute Cluster


vSAN storage
cluster

vSAN Stretched
storage cluster


**Note:**



Yes Yes Less than 1 ms
RTT.

No Yes Less than 1 ms
RTT.

No Yes Less than 1 ms
RTT within each
site.


No Yes Less than 1 ms
RTT within the
same site.


No Yes Less than 1 ms
RTT within each
site.

No Yes Less than 1 ms
RTT

No Yes Less than 1 ms
RTT within each
site.



NA NA NA


NA NA NA



Recommended
is 25 GbE or
higher (workload
dependent) and 5
ms RTT.


Recommended is
25 GbE or higher
and 5 ms RTT or
less.

Minimum 10 GbE
and 5 ms RTT.


Minimum 10 GbE
and 1 ms RTT

Recommended
is 25 GbE or
higher (workload
dependent) and 5
ms RTT.



Less than 200
ms RTT. Up to 10
hosts per site.

Less than 100 ms
RTT. 11–15 hosts
per site.

Less than 500 ms
RTT.



Less than 1 ms
RTT

Less than 200
ms RTT. Up to 10
hosts per site.

Less than 100 ms
RTT. 11–15 hosts
per site.



2 Mbps per 1000
components
(Maximum of 100
Mbps with 45 k
components).


2 Mbps per 1000
components
(Maximum of 1.5
Mbps).



NA NA



2 Mbps per 1000
components

2 Mbps per 1000
components
(Maximum of 100
Mbps with 45 k
components).



VMware by Broadcom 1608


VMware Cloud Foundation 9.0


vSAN recommends the use of 25 GbE or higher NICs in the vSAN hosts. NIC requirements assume that the packet loss
is not more than 0.0001% in vSAN. There can be a drastic impact on the vSAN performance, if any of these requirements
are exceeded.

[For more information about the vSAN stretched cluster NIC requirements, see vSAN Stretched Cluster Guide.](https://www.vmware.com/docs/vsan-stretched-cluster-guide)


**Bandwidth and Latency Requirements**


To ensure high performance and availability, vSAN clusters must meet certain bandwidth and network latency
requirements.

The bandwidth requirements between the primary and secondary sites of a vSAN stretched cluster depend on the vSAN
[workload, amount of data, and the way you want to handle failures. For more information, see vSAN Stretched Cluster](https://www.vmware.com/docs/vmw-vsan-stretched-cluster-bandwidth-sizing)
[Bandwidth Sizing.](https://www.vmware.com/docs/vmw-vsan-stretched-cluster-bandwidth-sizing)


**Table 825: Bandwidth and Latency Requirements**









|Site Communication|Bandwidth|Latency|
|---|---|---|
|Single Site||1ms latency RTT.|
|Site to Site|vSAN OSA: minimum of 10 GbEs<br>vSAN ESA: minimum of 10 GbEs<br>**Note:**<br>The bandwidth requirement is based on the<br>number of VMs being replicated between<br>sites.|Less than 5 ms latency RTT.<br>|
|Site to Witness|2 Mbps per 1000 vSAN components|•<br>Less than 500 ms latency RTT for 1<br>host per site.<br>•<br>Less than 200 ms latency RTT for up to<br>10 hosts per site.<br>•<br>Less than 100 ms latency RTT for 11-15<br>hosts per site.|
|vSAN Compute-Only Cluster to a vSAN<br>Storage Cluster||Minimum 5 ms latency RTT.|


**Layer 2 and Layer 3 Support**





VMware recommends Layer 2 connectivity for vSAN deployed on a single site. For vSAN deployed across multiple racks,
you can use Layer 2 or Layer 3. VMware recommends Layer 3 for data site to data site communication

vSAN also supports deployments using routed Layer 3 connectivity between vSAN hosts. You must consider the number
of hops and additional latency incurred while the traffic gets routed.


VMware by Broadcom 1609


VMware Cloud Foundation 9.0


**Table 826: Layer 2 and Layer 3 Support**







|Cluster Type|L2 Supported|L3 Supported|Considerations|
|---|---|---|---|
|Hybrid Cluster|Yes|Yes|L2 for single site and single<br>rack is recommended. L2 or L3<br>for single site, if vSAN cluster<br>is deployed across multiple<br>rack and/or using vSAN fault<br>domains.|
|All-Flash Cluster|Yes|Yes|L2 is recommended and L3 is<br>supported.|
|vSAN Stretched Cluster Data|Yes|Yes|Both L2 and L3 between data<br>sites are supported. Layer 3 is<br>recommended to isolate faults<br>per site. Layer 3 networking is<br>preferred for vSAN stretched<br>clusters as it helps avoid issues<br>with Spanning Tree Protocol<br>(STP) redirecting the traffic<br>across less desirable links.|
|vSAN Stretched Cluster Witness|No|Yes|L3 is supported. L2 between<br>data and witness sites is not<br>supported.|
|Two-Node vSAN Cluster|Yes|Yes|Both L2 and L3 between data<br>sites are supported.|
|vSAN Stretched Compute<br>Cluster|Yes|Yes|Both L2 and L3 between data<br>sites are supported.|
|vSAN Compute Client Traffic|Yes|Yes|Both L2 and L3 between data<br>sites are supported.|
|vSAN Storage Cluster|Yes|Yes|L2 is recommended and L3 is<br>supported.|
|vSAN Stretched Storage Cluster|Yes|Yes|Both L2 and L3 between data<br>sites are supported. Layer 3 is<br>recommended to isolate faults<br>per site. Layer 3 networking is<br>preferred for vSAN stretched<br>storage clusters as it helps<br>avoid issues with Spanning<br>Tree Protocol (STP) redirecting<br>the traffic across less desirable<br>links.|


**Routing and Switching Requirements**


All three sites in a vSAN stretched cluster communicate across the management network and across the vSAN network.
The VMs in all data sites communicate across a common virtual machine network.

Following are the vSAN stretched cluster routing requirements:


VMware by Broadcom 1610


VMware Cloud Foundation 9.0


**Table 827: ESXi Host Routing Requirements**

|Site Communication|Deployment Model|Layer|Routing|
|---|---|---|---|
|Site to Site|Default|Layer 2|Not required|
|Site to Site|Default|Layer 3|Use static routes or gateway<br>override. Recommended is<br>gateway override. SeeOverride<br>the Default Gateway of a<br>VMkernel Adapter.|
|Site to Witness|Default|Layer 3|Use static routes or gateway<br>override.|
|Site to Witness|Witness Traffic Separation|Layer 3|Use static routes or gateway<br>override when using an<br>interface other than the<br>Management (vmk0) interface.|
|Site to Witness|Witness Traffic Separation|Layer 2 for two-host cluster|Static routes are not required.|



**Virtual Switch Requirements**

You can create a vSAN network with either vSphere Standard Switch or vSphere Distributed Switch. Use a distributed
switch to prioritize bandwidth for vSAN traffic. vSAN uses a distributed switch with all the vCenter versions.

The following table compares the advantages and benefits of a distributed switch over a standard switch:


**Table 828: Virtual Switch Types**







|Design Requirement|Option 1 - vSphere Distributed<br>Switch|Option 2 - vSphere Standard<br>Switch|Description|
|---|---|---|---|
|Availability|No impact|No impact|You can use either of the<br>options|
|Manageability|Positive impact|Negative impact|The distributed switch is<br>centrally managed across all<br>hosts, unlike the standard switch<br>which is managed on each host<br>individually.|
|Performance|Positive impact|Negative impact|The distributed switch has<br>added controls, such as<br>Network I/O Control, which<br>you can use to guarantee<br>performance for vSAN traffic.|
|Recoverability|Positive impact|Negative impact|The distributed switch<br>configuration can be backed<br>up and restored, the standard<br>switch does not have this<br>functionality.|
|Security|Positive impact|Negative impact|The distributed switch has<br>added built-in security controls<br>to help protect traffic.|


VMware by Broadcom 1611


VMware Cloud Foundation 9.0


**vSAN Network Port Requirements**


vSAN deployments require specific network ports and settings to provide access and services.

vSAN sends messages on certain ports on each host in the cluster. Verify that the host firewalls allow traffic on these
ports. For the list of all supported vSAN ports and protocols, see the _Broadcom Ports and Protocols Portal_ [at https://](https://ports.broadcom.com/)
[ports.broadcom.com/.](https://ports.broadcom.com/)


**Network Firewall Requirements**


When you configure the network firewall, consider which version of vSAN you are deploying.

When you enable vSAN on a cluster, all required ports are added to ESXifirewall rules and configured automatically. You
do not need to open any firewall ports or enable any firewall services manually. You can view open ports for incoming and
outgoing connections in the ESXi host security profile ( **Configure > Security Profile** ).

**vsanEncryption Firewall Rule**

If your cluster uses vSAN encryption, consider the communication between hosts and the KMS server.

vSAN encryption requires a Key Management Server (KMS). vSAN can use a vCenter Native Key Provider or an external
KMS. vCenter obtains the key IDs from the KMS, and distributes them to the ESXi hosts. KMS servers and ESXi hosts
communicate directly with each other. KMS servers might use different port numbers, so the vsanEncryption firewall
rule enables you to simplify communication between each vSAN host and the KMS server. This allows a vSAN host to
communicate directly to any port on a KMS server (TCP port 0 through 65535).

When a host establishes communication to a KMS server, the following operations occur.

- The KMS server IP is added to the vsanEncryption rule and the firewall rule is enabled.

- Communication between vSAN node and KMS server is established during the exchange.

- After communication between the vSAN node and the KMS server ends, the IP address is removed from
vsanEncryption rule, and the firewall rule is deactivatedagain.

vSAN hosts can communicate with multiple KMS hosts using the same rule.

### **Configuring IP Network Transport**

Transport protocols provide communication services across the network. These services include the TCP/IP stack and
flow control.

vSAN does not support vSphere TCP/IP stacks.


**vSphere RDMA**

vSAN supports Remote Direct Memory Access (RDMA) communication.

RDMA allows direct memory access from the memory of one computer to the memory of another computer without
involving the operating system or CPU. The transfer of memory is offloaded to the RDMA-capable Host Channel Adapters
(HCA).

vSAN supports the RoCE v2 protocol. RoCE v2 requires a network configured for lossless operation that is free of
congestion. If your network has congestion, certain large I/O workloads might experience lower performance than TCP.

Each vSAN host must have a vSAN certified RDMA-capable NIC, as listed in the vSAN section of the _Broadcom_
_Compatibility Guide_ . Use only the same model network adapters from the same vendor on each end of the connection.

**Note:**


VMware by Broadcom 1612


VMware Cloud Foundation 9.0


vSphere RDMA is not supported on vSAN stretched clusters, two-node vSAN clusters, vSAN storage clusters, or
datastore sharing (HCI Mesh).

All hosts in the cluster must support RDMA. If any host loses RDMA support, the entire vSAN cluster switches to TCP.

vSAN with RDMA supports NIC failover, but does not support LACP or IP-hash-based NIC teaming.


**IPv6 Support**

vSAN supports IPv6.


vSAN supports the following IP versions.

- IPv4

- IPv6

For more information about using IPv6, consult with your network vendor.


**Static Routes**

You can use static routes to allow vSAN network interfaces from hosts on one subnet to reach the hosts on another
network.

Most organizations separate the vSAN network from the management network, so the vSAN network does not have a
default gateway. In an L3 deployment, hosts that are on different subnets or different L2 segments cannot reach each
other over the default gateway, which is typically associated with the management network.

Use _static routes_ to allow the vSAN network interfaces from hosts on one subnet to reach the vSAN networks on hosts on
the other network. Static routes instruct a host how to reach a particular network over an interface, rather than using the
default gateway.

The following example shows how to add an IPv4 static route to an ESXi host. Specify the gateway (-g) and the network (n) you want to reach through that gateway:
```
 esxcli network ip route ipv4 add –g 172.16.10.253 -n 192.168.10.0/24
```

When the static routes have been added, vSAN traffic connectivity is available across all networks, assuming the physical
infrastructure allows it. Run the `vmkping` command to test and confirm communication between the different networks by
pinging the IP address or the default gateway of the remote network. You also can check different size packets (-s) and
prevent fragmentation (-d) of the packet.
```
 vmkping –I vmk3 192.168.10.253

```

**Jumbo Frames**

vSAN fully supports jumbo frames on the vSAN network.

Jumbo frames are Ethernet frames with more than 1500 bytes of payload. Jumbo frames typically carry up to 9000 bytes
of payload, but variations exist.

Using jumbo frames can reduce CPU utilization and improve throughput.

**Note:**

Enable jumbo frames support for vSAN storage cluster deployments to improve performance.

You must decide whether these gains outweigh the overhead of implementing jumbo frames throughout the network. In
data centers where jumbo frames are already enabled in the network infrastructure, you can use them for vSAN. The


VMware by Broadcom 1613


VMware Cloud Foundation 9.0


operational cost of configuring jumbo frames throughout the network might outweigh the limited CPU and performance
benefits.

### **Using VMware NSX with vSAN**

vSAN and VMware NSX can be deployed and coexist in the same vSphere infrastructure. A distributed vSwitch can
support NSX and vSphere or vSAN traffic

NSX does not support the configuration of the vSAN data network over an NSX-managed VXLAN or Geneve overlay.

vSAN and NSX are compatible. vSAN and NSX are not dependent on each other to deliver their functionalities, resources,
and services.

### **Using Congestion Control and Flow Control**

Flow control is used to manage the rate of data transfer between senders and receivers on the network. Congestion
control handles congestion in the network. Flow control is enabled by default on the ESXi hosts.


**Flow Control**

You can use flow control to manage the rate of data transfer between two devices.

Flow control is configured when two physically connected devices perform auto-negotiation. An overwhelmed network
node might send a pause frame to halt the transmission of the sender for a specified period.

One reason to use pause frames is to support network interface controllers (NICs) that do not have enough buffering to
handle full-speed reception. This problem is uncommon with advances in bus speeds and memory sizes.


**Congestion Control**

Congestion control helps you control the traffic on the network.

Congestion control applies mainly to packet switching networks. Network congestion within a switch might be caused by
overloaded inter-switch links. If inter-switch links overload the capability on the physical layer, the switch introduces pause
frames to protect itself.


**Priority Flow Control**

Priority-based flow control (PFC) helps you eliminate frame loss due to congestion.

[Priority-based flow control (IEEE 802.1Qbb) is achieved by a mechanism similar to pause frames, but operates on](http://www.ieee802.org/1/pages/802.1bb.html)
individual priorities. PFC is also called Class-Based Flow Control (CBFC) or Per Priority Pause (PPP).


**Flow Control Design Considerations**

By default, flow control is enabled on all network interfaces in ESXi hosts.

Flow control configuration on a NIC is done by the driver. When a NIC is overwhelmed by network traffic, the NIC sends
pause frames.

Flow control mechanisms such as pause frames can trigger overall latency in the VM guest I/O due to increased latency
at the vSAN network layer. Some network drivers provide module options that configure flow control functionality within
[the driver. For information about configuring flow control on ESXi hosts, see Broadcom knowledge base article 1013413.](https://knowledge.broadcom.com/external/article?legacyId=1013413)

In deployments with 1 GbEs, leave flow control enabled on ESXi network interfaces (default). If pause frames are a
problem, carefully plan disabling flow control in conjunction with Hardware Vendor Support or Broadcom Global Support
Services.


VMware by Broadcom 1614


VMware Cloud Foundation 9.0


To learn how you can recognize the presence of pause frames being sent from a receiver to an ESXi host, see
Troubleshooting the vSAN Network. A large number of pause frames in an environment usually indicates an underlying
network or transport issue to investigate.

### **Basic NIC Teaming, Failover, and Load Balancing**

For IP storage based solutions such as vSAN, it is best practice to implement network redundancy.

You can use NIC teaming to achieve network redundancy. You can configure two or more network adapters (NICs)
as a team for high availability and load balancing. Basic NIC teaming is available with vSphere networking, and these
techniques can affect vSAN design and architecture.

Several NIC teaming options are available. Avoid NIC teaming policies that require physical switch configurations, or
that require an understanding of networking concepts such as Link Aggregation. Best results are achieved with a basic,
simple, and reliable setup.

If you are not sure about NIC teaming options, use an Active/Standby configuration with explicit failover.


**Basic NIC Teaming**

Basic NIC teaming uses multiple physical uplinks, one vmknic, and a single switch.

vSphere NIC teaming uses multiple uplink adapters, called vmnics, which are associated with a single virtual switch
to form a team. This is the most basic option, and you can configure it using a standard vSphere standard switch or a
vSphere distributed switch.


**Failover and Redundancy**

vSAN can use the basic NIC teaming and failover policy provided by vSphere.

NIC teaming on a vSwitch can have multiple active uplinks, or an Active/Standby uplink configuration. Basic NIC teaming
does not require any special configuration at the physical switch layer.


VMware by Broadcom 1615


VMware Cloud Foundation 9.0


**Note:** vSAN does not use NIC teaming for load balancing.

A typical NIC teaming configuration has the following settings. When working on distributed switches, edit the settings of
the distributed port group used for vSAN traffic.

- Load balancing: Route based on originating virtual port

- Network failure detection: Link status only

- Notify switches: Yes

- Failback: Yes


**Configure Load Balancing for NIC Teams**


Several load-balancing techniques are available for NIC teaming, and each technique has its pros and cons.


**Route Based on Originating Virtual Port**

In Active/Active or Active/Passive configurations, use **Route based on originating virtual port** for basic NIC teaming.
When this policy is in effect, only one physical NIC is used per VMkernel port.

**Pros**

- This is the simplest NIC teaming method that requires minimal physical switch configuration.

- This method requires only a single port for vSAN traffic, which simplifies troubleshooting.

**Cons**

- A single VMkernel interface is limited to a single physical NIC's bandwidth. As typical vSAN environments use one
VMkernel adapter, only one physical NIC in the team is used.


**Route Based on Physical NIC Load**

**Route Based on Physical NIC Load** is based on **Route Based on Originating Virtual Port**, where the virtual switch
monitors the actual load of the uplinks and takes steps to reduce load on overloaded uplinks. This load-balancing method
is available only with a vSphere Distributed Switch, not on vSphere Standard Switches.

The distributed switch calculates uplinks for each VMkernel port by using the port ID and the number of uplinks in the NIC
team. The distributed switch checks the uplinks every 30 seconds, and if the load exceeds 75 percent, the port ID of the
VMkernel port with the highest I/O is moved to a different uplink.

**Pros**

- No physical switch configuration is required.

- Although vSAN has one VMkernel port, the same uplinks can be shared by other VMkernel ports or network services.
vSAN can benefit by using different uplinks from other contending services, such as vMotion or management.

**Cons**

- As vSAN typically only has one VMkernel port configured, its effectiveness is limited.

- The ESXi VMkernel reevaluates the traffic load after each time interval, which can result in processing overhead.


**Settings: Network Failure Detection**

Use the default setting: **Link status only** . Do not use Beacon probing for link failure detection. Beacon probing requires
at least three physical NICs to avoid split-brain scenarios. There can be a network traffic failover if the ESXi host detects a
[link down event on an ESXi host network interface. For more details, see Broadcom kbnowledge ase article 1005577.](https://knowledge.broadcom.com/external/article?legacyId=1005577)


VMware by Broadcom 1616


VMware Cloud Foundation 9.0


**Settings: Notify Switches**

Use the default setting: **Yes** . Physical switches have MAC address forwarding tables to associate each MAC address
with a physical switch port. When a frame comes in, the switch determines the destination MAC address in the table and
decides the correct physical port.

If a NIC failover occurs, the ESXi host must notify the network switches that something has changed, or the physical
switch might continue to use the old information and send the frames to the wrong port.

When you set Notify Switches to **Yes**, if one physical NIC fails and traffic is rerouted to a different physical NIC in the
team, the virtual switch sends notifications over the network to update the lookup tables on physical switches.

This setting does not catch VLAN misconfigurations, or uplink losses that occur further upstream in the network. The
vSAN network partitions health check can detect these issues.


**Settings: Failback**

This option determines how a physical adapter is returned to active duty after recovering from a failure. A failover event
triggers the network traffic to move from one NIC to another. When a **link up** state is detected on the originating NIC,
traffic automatically reverts to the original network adapter when Failback is set to **Yes** . When Failback is set to **No**, a
manual failback is required.

Setting Failback to **No** can be useful in some situations. For example, after a physical switch port recovers from a failure,
the port might be active but can take several seconds to begin forwarding traffic. Automatic Failback has been known to
cause problems in certain environments that use the Spanning Tree Protocol. For more information about Spanning Tree
[Protocol (STP), see Broadcom knowledge base article 1003804.](https://knowledge.broadcom.com/external/article?legacyId=1003804)


**Setting Failover Order**

Failover order determines which links are active during normal operations, and which links are active in the event of a
failover. Different supported configurations are possible for the vSAN network.

**Active/Standby uplinks** : If a failure occurs on an Active/Standby setup, the NIC driver notifies vSphere of a link down
event on Uplink 1. The standby Uplink 2 becomes active, and traffic resumes on Uplink 2.

**Active/Active uplinks** : If you set the failover order to Active/Active, the virtual port used by vSAN traffic cannot use both
physical ports at the same time.

If your NIC teaming configuration for both Uplink 1 and Uplink 2 is active, there is no need for the standby uplink to
become active.

**Note:** When using an Active/Active configuration, ensure that Failback is set to **No** . For more information, see Broadcom
[knowledge base article 2072928.](https://knowledge.broadcom.com/external/article?legacyId=2072928)

### **Advanced NIC Teaming**

You can use advanced NIC teaming methods with multiple VMkernel adapters having two dedicated subnets to configure
the vSAN network. If you use Link Aggregation Protocol (LAG/LACP), the vSAN network can be configured with a single
VMkernel adapter.

You can use advanced NIC teaming to implement an air gap, so a failure that occurs on one network path does not impact
the other network path. If any part of one network path fails, the other network path can carry the traffic. Configure multiple
VMkernel NICs for vSAN on different subnets, such as another VLAN or separate physical network fabric.

vSphere and vSAN do not support multiple VMkernel adapters (vmknics) on the same subnet. For more details, see
[Broadcom knowledge base article 2010877.](https://knowledge.broadcom.com/external/article?legacyId=2010877)


VMware by Broadcom 1617


VMware Cloud Foundation 9.0


**Link Aggregation Group Overview**

By using the LACP protocol, a network device can negotiate an automatic bundling of links by sending LACP packets to a
peer.

A Link Aggregation Group (LAG) states that Link Aggregation allows one or more links to be aggregated together to form
a Link Aggregation Group.

LAG can be configured as either static (manual) or dynamic by using LACP to negotiate the LAG formation. LACP can be
configured as follows:

**Active** Devices immediately send LACP messages when the port comes
up. End devices with LACP enabled (for example, ESXi hosts
and physical switches) send and receive frames called LACP
messages to each other to negotiate the creation of a LAG.

**Passive** Devices place a port into a passive negotiating state, in which the
port only responds to received LACP messages, but do not initiate
negotiation.

**Note:** If the host and switch are both in passive mode, the LAG does not initialize, because an active part is required to
trigger the linking. At least one must be Active.

[For more information about LACP support on a vSphere Distributed Switch, see the vSphere Networking guide.](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/vsphere-networking.html)

**Note:** The number of LAGs you can use depends on the capabilities of the underlying physical environment and the
topology of the virtual network.


**Static and Dynamic Link Aggregation**


You can use LACP to combine and aggregate multiple network connections.

When LACP is in **active** or **dynamic** mode, a physical switch sends LACP messages to network devices, such as ESXi
hosts, to negotiate the creation of a Link Aggregation Group (LAG).


VMware by Broadcom 1618


VMware Cloud Foundation 9.0


To configure Link Aggregation on hosts using vSphere Standard Switches (and pre-5.5 vSphere Distributed Switches),
configure a static channel-group on the physical switch. See your vendor documentation for more details.


**Pros and Cons of Dynamic Link Aggregation**

Consider the tradeoffs to using Dynamic Link Aggregation.

**Pros**

**Improves performance and bandwidth** . One vSAN host or VMkernel port can communicate with many other vSAN
hosts using many different load-balancing options.

**Provides network adapter redundancy** . If a NIC fails and the link-state fails, the remaining NICs in the team continue to
pass traffic.

**Improves traffic balancing** . Balancing of traffic after failures is automatic and fast.

**Cons**

**Less flexible** . Physical switch configuration requires that physical switch ports be configured in a port-channel
configuration.

**More complex** . Use of multiple switches to produce full physical redundancy configuration is complex. Vendor-specific
implementations add to the complexity.


**Static LACP with Route Based on IP Hash**


You can create a vSAN cluster using static LACP with an IP-hash policy. This section focuses on vSphere Standard
Switches, but you also can use vSphere Distributed Switches.

You can use the Route based on IP Hash load balancing policy.

Select **Route based on IP Hash** load balancing policy at a vSwitch or port-group level. Set all uplinks assigned to static
channel group to the Active Uplink position on the Teaming and Failover Policies at the virtual switch or port-group level.


VMware by Broadcom 1619


VMware Cloud Foundation 9.0


When IP Hash is configured on a vSphere port group, the port group uses the **Route based on IP Hash** policy. The
number of ports in the port-channel must be same as the number of uplinks in the team.


**Pros and Cons of Static LACP with IP Hash**

Consider the tradeoffs to using Static LACP with IP Hash.

**Pros**

- **Improves performance and bandwidth** . One vSAN host or VMkernel port can communicate with many other vSAN
hosts using the IP Hash algorithm.

- **Provides network adapter redundancy** . If a NIC fails and the link-state fails, the remaining NICs in the team continue
to pass traffic.

- **Adds flexibility** . You can use IP Hash with both vSphere Standard Switches and vSphere Distributed Switches.

**Cons**

- **Physical switch configuration is less flexible** . Physical switch ports must be configured in a static port-channel
configuration.

- **Increased chance of misconfiguration** . Static port-channels form without any verification on either end (unlike LACP
dynamic port-channel).

- **More complex** . Introducing full physical redundancy configuration increases complexity when multiple switches are
used. Implementations can become quite vendor specific.


VMware by Broadcom 1620


VMware Cloud Foundation 9.0


- **Limited load balancing** . If your environment has only a few IP addresses, the virtual switch might consistently pass
the traffic through one uplink in the team. This can be especially true for small vSAN clusters.


**Understanding Network Air Gaps**

You can use advanced NIC teaming methods to create an air-gap storage fabric. Two storage networks are used to create
a redundant storage network topology, with each storage network physically and logically isolated from the other by an air
gap.

You can configure a network air gap for vSAN in a vSphere environment. Configure multiple VMkernel ports per vSAN
host. Associate each VMkernel port to dedicated physical uplinks, using either a single vSwitch or multiple virtual
switches, such as vSphere Standard Switch or vSphere Distributed Switch.


Typically, each uplink must be connected to fully redundant physical infrastructure.

This topology is not ideal. The failure of components such as NICs on different hosts that reside on the same network can
lead to interruption of storage I/O. To avoid this problem, implement physical NIC redundancy on all hosts and all network
segments. Configuration example 2 addresses this topology in detail.

These configurations are applicable to both L2 and L3 topologies, with unicast configuration.


**Pros and Cons of Air Gap Network Configurations with vSAN**

Network air gaps can be useful to separate and isolate vSAN traffic. Use caution when configuring this topology.

**Pros**

- Physical and logical separation of vSAN traffic.

**Cons**

- vSAN does not support multiple VMkernel adapters (vmknics) on the same subnet. For more information, see
[Broadcom knowledge base article 2010877.](https://knowledge.broadcom.com/external/article?legacyId=2010877)

- Setup is complex and error prone, so troubleshooting is more complex.

- Network availability is not guaranteed with multiple vmknics in some asymmetric failures, such as one NIC failure on
one host and another NIC failure on another host.

- Load-balanced vSAN traffic across physical NICs is not guaranteed.

- Costs increase for vSAN hosts, as you might need multiple VMkernel adapters (vmknics) to protect multiple physical
NICs (vmnics). For example, 2 x 2 vmnics might be required to provide redundancy for two vSAN vmknics.

- Required logical resources are doubled, such as VMkernel ports, IP addresses, and VLANs.

- vSAN does not implement port binding. This means that techniques such as multi-pathing are not available.


VMware by Broadcom 1621


VMware Cloud Foundation 9.0


- Layer 3 topologies are not suitable for vSAN traffic with multiple vmknics. These topologies might not function as
expected.

Dynamic LACP combines, or aggregates, multiple network connections in parallel to increase throughput and provide
redundancy. When NIC teaming is configured with LACP, load balancing of the vSAN network across multiple uplinks
occurs. This load balancing happens at the network layer, and is not done through vSAN.

**Note:** Other terms sometimes used to describe link aggregation include port trunking, link bundling, Ethernet/network/NIC
bonding, EtherChannel.

This section focuses on Link Aggregation Control Protocol (LACP). The IEEE standard is 802.3ad, but some vendors
have proprietary LACP features, such as PAgP (Port Aggregation Protocol). Follow the best practices recommended by
your vendor.

**Note:** The LACP support introduced in vSphere Distributed Switch 5.1 only supports IP-hash load balancing. vSphere
Distributed Switch 5.5 and later fully support LACP.

LACP is an industry standard that uses port-channels. Many hashing algorithms are available. The vSwitch port-group
policy and the port-channel configuration must agree and match.


**NIC Teaming Configuration Examples**

The following NIC teaming configurations illustrate typical vSAN networking scenarios.

**Configuration 1: Single vmknic, Route Based on Physical NIC Load**


You can configure basic Active/Active NIC Teaming with the **Route based on Physical NIC Load** policy for vSAN hosts.
Use a vSphere Distributed Switch (vDS).

For this example, the vDS must have two uplinks configured for each host. A distributed port group is designated for vSAN
traffic and isolated to a specific VLAN. Jumbo frames are already enabled on the vDS with an MTU value of 9000.

Configure teaming and failover for the distributed port group for vSAN traffic as follows:

- Load balancing policy set to **Route Based on Physical Nic Load** .

- Network failure detection set to **Link status only** .

- Notify Switches set to **Yes** .

- Failback set to **No** . You can set Failback to **yes**, but not for this example.

- Ensure both uplinks are in the **Active uplinks** position.


**Network Uplink Redundancy Lost**

When the link down state is detected, the workload switches from one uplink to another. There is no noticeable impact to
the vSAN cluster and VM workload.


**Recovery and Failback**

When you set **Failback** to **No**, traffic is not promoted back to the original vmnic. If **Failback** is set to **Yes**, traffic is
promoted back to the original vmnic on recovery.


**Load Balancing**

Since this is a single VMkernel NIC, there is no performance benefit to using **Route based on physical load** .

Only one physical NIC is in use at any time. The other physical NIC is idle.


VMware by Broadcom 1622


VMware Cloud Foundation 9.0


**Configuration 2: Multiple vmknics, Route Based on Originating Port ID**


You can use two non-routable VLANs that are logically and physically separated, to produce an air-gap topology.

This example provides configuration steps for a vSphere distributed switch, but you also can use vSphere standard
switches. It uses two 10 GbE physical NICs and logically separates them on the vSphere networking layer.

Create two distributed port groups for each vSAN VMkernel vmknic. Each port group has a separate VLAN tag. For vSAN
VMkernel configuration, two IP addresses on both VLANs are required for vSAN traffic.

**Note:**

Practical implementations typically use four physical uplinks for full redundancy.

For each port group, the teaming and failover policy use the default settings.

- Load balancing set to **Route based on originating port ID**

- Network failure detection set to **Link Status Only**

- Notify Switches set to the default value of **Yes**

- Failback set to the default value of **Yes**

- The uplink configuration has one uplink in the **Active** position and one uplink in the **Unused** position.

One network is completely isolated from the other network.


**vSAN Port Group 1**

This example uses a distributed port group called **vSAN-DPortGroup-1** . **VLAN 3266** is tagged for this port group with the
following Teaming and Failover policy:

- Traffic on the port group tagged with VLAN 3266

- Load balancing set to **Route based on originating port ID**

- Network failure detection set to **Link Status Only**

- Notify Switches set to default value of **Yes**

- Failback set to default value of **Yes**

- The uplink configuration has **Uplink 1** in the **Active** position and **Uplink 2** in the **Unused** position.


**vSAN Port Group 2**

To complement vSAN port group 1, configure a second distributed port group called **vSAN-portgroup-2**, with the following
differences:

- Traffic on the port group tagged with VLAN 3265

- The uplink configuration has **Uplink 2** in the **Active** position and **Uplink 1** in the **Unused** position.


**vSAN VMkernel Port Configuration**

Create two vSAN VMkernel interfaces and on both port groups. In this example, the port groups are named **vmk1** and
**vmk2** .

- **vmk1** is associated with VLAN 3266 (172.40.0.xx), and as a result port group **vSAN-DPortGroup-1** .

- **vmk2** is associated with VLAN 3265 (192.60.0.xx), and as a result port group **vSAN-DPortGroup-2** .


**Load Balancing**

vSAN has no load balancing mechanism to differentiate between multiple vmknics, so the vSAN I/O path chosen is not
deterministic across physical NICs. The vSphere performance charts show that one physical NIC is often more utilized


VMware by Broadcom 1623


VMware Cloud Foundation 9.0


than the other. A simple I/O test performed in our labs, using 120 VMs with a 70:30 read/write ratio with a 64K block size
on a four-host all flash vSAN cluster, revealed an unbalanced load across NICs.

vSphere performance graphs show an unbalanced load across NICs.


**Network Uplink Redundancy Lost**

Consider a network failure introduced in this configuration. vmnic1 is not enabled on a given vSAN host. As a result, port
**vmk2** is impacted. A failing NIC triggers both network connectivity alarms and redundancy alarms.

For vSAN, this failover process triggers approximately **10 seconds** after CMMDS (Cluster Monitoring, Membership,
and Directory Services) detects a failure. During failover and recovery, vSAN stops any active connections on the failed
network, and attempts to re-establish connections on the remaining functional network.

Since two separate vSAN VMkernel ports communicate on isolated VLANs, vSAN health check failures might be
triggered. This is expected as **vmk2** can no longer communicate to its peers on VLAN 3265.

The performance charts show that the affected workload has restarted on vmnic0, since vmnic1 has a failure. This test
illustrates an important distinction between vSphere NIC teaming and this topology. vSAN attempts to re-establish or
restart connections on the remaining network.

However, in some failure scenarios, recovering the impacted connections might require up to **90 seconds** to complete,
due to ESXi TCP connection timeout. Subsequent connection attempts might fail, but connection attempts time out at 5
seconds, and the attempts rotate through all possible IP addresses. This behavior might affect virtual machine guest I/O.
As a result, application and virtual machine I/O might have to be retried.

For example, on Windows Server 2012 VMs, Event IDs 153 (device reset) and 129 (retry events) might be logged during
the failover and recovery process. In the example, event ID 129 was logging for approximately 90 seconds until the I/O
was recovered.

You might have to modify disk timeout settings of some guest OSes to ensure that they are not severely impacted. Disk
timeout values might vary, depending on the presence of VMware Tools, and the specific guest OS type and version.


**Recovery and Failback**

When the network is repaired, workloads are not automatically rebalanced unless another failure to force workload occurs,
due to another failure. As soon as the impacted network is recovered, it becomes available for new TCP connections.


**Configuration 3: Dynamic LACP**


You can configure a two-port LACP port channel on a switch and a two-uplink Link Aggregation Group on a vSphere
distributed switch.

In this example, use 10 GbE networking with two physical uplinks per server.

**Note:**

vSAN over RDMA does not support this configuration.


**Configure the Network Switch**

Configure the vSphere distributed switch with the following settings.

- Identify the ports in question where the vSAN host will connect.

- Create a port channel.

- If using VLANs, then trunk the correct VLAN to the port channel.

- Configure the desired distribution or load-balancing options (hash).

- Setting LACP mode to active/dynamic.


VMware by Broadcom 1624


VMware Cloud Foundation 9.0


- Verify MTU configuration.


**Configure vSphere**

Configure the vSphere network with the following settings.

- Configure vDS with the correct MTU.

- Add hosts to vDS.

- Create a LAG with the correct number of uplinks and matching attributes to port channel.

- Assign physical uplinks to the LAG.

- Create a distributed port group for vSAN traffic and assign correct VLAN.

- Configure VMkernel ports for vSAN with correct MTU.


**Set Up the Physical Switch**

Configure the physical switch with the following settings. For guidance about how to set up this configuration on
[Dell servers based on Dell Networking PowerConnect Switch, refer to: http://www.dell.com/Support/Article/us/en/19/](http://www.dell.com/Support/Article/us/en/19/HOW10364/h)
[HOW10364.](http://www.dell.com/Support/Article/us/en/19/HOW10364/h)

Configure a two uplink LAG:

- Use switch ports 36 and 18.

- This configuration uses VLAN trunking, so port channel is in VLAN trunk mode, with the appropriate VLANs trunked.

- Use the following method for load-balancing or load distribution: **Source and destination IP addresses, TCP/UDP**
**port and VLAN**

- Verify that the LACP mode is **Active** (Dynamic).

Use the following commands to configure an individual port channel on a Dell switch:

- Create a port-channel.
```
# interface port-channel 1
```

- Set port-channel to VLAN trunk mode.
```
# switchport mode trunk
```

- Allow VLAN access.
```
# switchport trunk allowed vlan 3262
```

- Configure the load balancing option.
```
# hashing-mode 6
```

- Assign the correct ports to the port-channel and set the mode to Active.


VMware by Broadcom 1625


VMware Cloud Foundation 9.0


- Verify that the port channel is configured correctly.
```
 # show interfaces port-channel 1

 Channel Ports Ch-Type Hash Type Min-links Local Prf
 ------- ----------------------------- -------- --------- --------- -------- Po1 Active: Te1/0/36, Te1/0/18 Dynamic  6 1 Disabled
 Hash Algorithm Type
 1 - Source MAC, VLAN, EtherType, source module and port Id
 2 - Destination MAC, VLAN, EtherType, source module and port Id
 3 - Source IP and source TCP/UDP port
 4 - Destination IP and destination TCP/UDP port
 5 - Source/Destination MAC, VLAN, EtherType, source MODID/port
 6 - Source/Destination IP and source/destination TCP/UDP port
 7 - Enhanced hashing mode
# interface range Te1/0/36, Te1/0/18
# channel-group 1 mode active
```

Full configuration:
```
# interface port-channel 1
# switchport mode trunk
# switchport trunk allowed vlan 3262
# hashing-mode 6
# exit
# interface range Te1/0/36,Te1/018
# channel-group 1 mode active
# show interfaces port-channel 1
```

**Note:** Repeat this procedure on all participating switch ports that are connected to vSAN hosts.


**Set Up vSphere Distributed Switch**

Before you begin, make sure that the vDS is upgraded to a version that supports LACP. To verify, right click the vDS, and
check if the Upgrade option is available. You might have to upgrade the vDS to a version that supports LACP.


**Create LAG on vDS**

To create a LAG on a distributed switch, select the vDS, click the **Configure** tab, and select **LACP** . Add a new LAG.

Configure the LAG with the following properties:

- LAG name: **lag1**

- Number of ports: **2** (to match port channel on switch)

- Mode: **Active**, to match the physical switch.

- Load balancing mode: **Source and destination IP addresses, TCP/UDP port and VLAN**


**Add Physical Uplinks to LAG**

vSAN hosts have been added to the vDS. Assign the individual vmnics to the appropriate LAG ports.


VMware by Broadcom 1626


VMware Cloud Foundation 9.0


- Right click the vDS, and select **Add and Manage Hosts…**

- Select **Manage Host Networking**, and add your attached hosts.

- On **Manage Physical Adapters**, select the appropriate adapters and assign them to the LAG port.

- Migrate vmnic0 from Uplink 1 position to port 0 on LAG1.

Repeat the procedure for vmnic1 to the second LAG port position, lag1-1.


**Configure Distributed Port Group Teaming and Failover Policy**

Assign the LAG group as an **Active uplink** on distributed port group teaming and failover policy. Select or create the
designated distributed port group for vSAN traffic. This configuration uses a vSAN port group called **vSAN** with VLAN ID
3262 tagged. Edit the port group, and configure Teaming and Failover Policy to reflect the new LAG configuration.

Ensure the LAG group **lag1** is in the active uplinks position, and ensure the remaining uplinks are in the **Unused** position.

**Note:** When a link aggregation group (LAG) is selected as the only active uplink, the load-balancing mode of the LAG
overrides the load-balancing mode of the port group. Therefore, the following policy plays no role: **Route based on**
**originating virtual port** .


**Create the VMkernel Interfaces**

The final step is to create the VMkernel interfaces to use the new distributed port group, ensuring that they are tagged for
vSAN traffic. Observe that each vSAN vmknic can communicate over vmnic0 and vmnic1 on a LAG group to provide load
balancing and failover.


**Configure Load Balancing**

From a load balancing perspective, there is not a consistent balance of traffic across all hosts on all vmnics in this LAG
setup, but there is more consistency compared to **Route based on physical NIC load** used in Configuration 1 and the
air-gapped/multiple vmknics method used in Configuration 2.

The individual hosts’ vSphere performance graph shows improved load balancing.


**Network Uplink Redundancy Lost**

When vmnic1 is not enabled on a given vSAN host, a Network Redundancy alarm is triggered.

No vSAN health alarms are triggered, and the impact to Guest I/O is minimal compared to the air-gapped, multi-vmknics
configuration. This configuration does not have to stop any TCP sessions with LACP configured.


**Recovery and Failback**

In a failback scenario, the behavior differs between Load Based Teaming, multiple vmknics, and LACP in a vSAN
environment. After vmnic1 recovers, traffic is automatically balanced across both active uplinks. This behavior can be
advantageous for vSAN traffic.


**Failback Set to Yes or No?**

A LAG load-balancing policy overrides the Teaming and Failover policy for vSphere distributed port groups. Also consider
the guidance on Failback value. Lab tests show no discernable behavior differences between Failback set to **yes** or **no**
with LACP. LAG settings takes priority over the port-group settings.

**Note:** Network failure detection values remain as **link status only**, since beacon probing is not supported with LACP.
[See Broadcom knowledge base article Understanding IP Hash load balancing (2006129).](https://knowledge.broadcom.com/external/article?legacyId=2006129)


VMware by Broadcom 1627


VMware Cloud Foundation 9.0


**Configuration 4: Static LACP – Route Based on IP Hash**


You can use a two-port LACP static port-channel on a switch, and two active uplinks on a vSphere Standard Switch.

In this configuration, use 10 GbE networking with two physical uplinks per server. A single VMkernel interface (vmknic) for
vSAN exists on each host.

For more information about host requirements and configuration examples, see the following Broadcom knowledge base
articles:

- [Host requirements for link aggregation for ESX (1001938)](https://knowledge.broadcom.com/external/article?legacyId=1001938)

- [Sample configuration of EtherChannel / Link Aggregation Control Protocol (LACP) with ESX and Cisco/HP switches](https://knowledge.broadcom.com/external/article?legacyId=1004048)
[(KB 1004048)](https://knowledge.broadcom.com/external/article?legacyId=1004048)

**Note:**

vSAN over RDMA does not support this configuration.


**Configure the Physical Switch**

Configure a two-uplink static port-channel as follows:

- Switch ports 43 and 44

- VLAN trunking, so port-channel is in VLAN trunk mode, with the appropriate VLANs trunked.

- Do not specify the load-balancing policy on the port-channel group.

These steps can be used to configure an individual port-channel on the switch:

Step 1: Create a port-channel.
```
#interface port-channel 13
```

Step 2: Set port-channel to VLAN trunk mode.
```
#switchport mode trunk
```

Step 3: Allow appropriate VLANs.
```
#switchport trunk allowed vlan 3266
```

Step 4: Assign the correct ports to the port-channel and set mode to active.
```
#interface range Te1/0/43, Te1/0/44
#channel-group 1 mode on
```

Step 5: Verify that the port-channel is configured as a static port-channel.
```
#show interfaces port-channel 13

Channel Ports Ch-Type Hash Type Min-links Local Prf
------- ----------------------------- -------- --------- --------- -Po13 Active: Te1/0/43, Te1/0/44 Static  7 1 Disabled
Hash Algorithm Type
1 - Source MAC, VLAN, EtherType, source module and port Id
2 - Destination MAC, VLAN, EtherType, source module and port Id
3 - Source IP and source TCP/UDP port

```

VMware by Broadcom 1628


VMware Cloud Foundation 9.0

```
4 - Destination IP and destination TCP/UDP port
5 - Source/Destination MAC, VLAN, EtherType, source MODID/port
6 - Source/Destination IP and source/destination TCP/UDP port
7 - Enhanced hashing mode

```

**Configure vSphere Standard Switch**

This example assumes you understand the configuration and creation of vSphere Standard Switches.

This example uses the following configuration:

- Uplinks named vmnic0 and vmnic1

- VLAN 3266 trunked to the switch ports and port-channel

- Jumbo frames

On each host, create a **vSwitch1** with MTU set to 9000, and vmnic0 and vmnic1 added to the vSwitch. On the Teaming
and Failover Policy, set both adapters to the **Active** position. Set the Load Balancing Policy to **Route Based on IP Hash** .

Configure teaming and failover for the distributed port group for vSAN traffic as follows:

- Load balancing policy set to **Route Based on IP hash** .

- Network failure detection set to **Link status only** .

- Notify Switches set to **Yes** .

- Failback set to **Yes** .

- Ensure both uplinks are in the **Active uplinks** position.

Use defaults for network detection, Notify Switches and Failback. All port groups inherit the Teaming and Failover Policy
that was set at the vSwitch level. You can override individual port group teaming and failover polices to differ from the
parent vSwitch, but make sure you use the same set of uplinks for IP hash load balancing for all port groups.


**Configure Load Balancing**

Although both physical uplinks are utilized, there is not a consistent balance of traffic across all physical vmnics. The
figure shows that only active traffic is vSAN traffic, which was essentially four vmknics or IP addresses. The behavior
might be caused by the low number of IP addresses and possible hashes. However, in some situations, the virtual switch
might consistently pass the traffic through one uplink in the team. For further details on the IP Hash algorithm, see the
[vSphere Networking guide.](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/vsphere-networking.html)


**Network Redundancy**

In this example, vmnic1 is connected to a port that has been disabled from the switch, to focus on failure and redundancy
behavior. Note that a network uplink redundancy alarm has triggered.

No vSAN health alarms were triggered. Cluster and VM components are not affected and Guest Storage I/O is not
interrupted by this failure.


**Recovery and Failback**

Once vmnic1 recovers, traffic is automatically balanced across both active uplinks.

### **Network I/O Control**

Use vSphere Network I/O Control to set Quality of Service (QoS) levels on network traffic.


VMware by Broadcom 1629


VMware Cloud Foundation 9.0


vSphere Network I/O Control is a feature available with vSphere Distributed Switches. Use it to implement Quality of
Service (QoS) on network traffic. This can be useful for vSAN when vSAN traffic must share the physical NIC with other
traffic types, such as vMotion, management, and VMs.


**Reservations, Shares, and Limits**

You can set a **reservation** so that Network I/O Control guarantees minimum bandwidth is available on the physical
adapter for vSAN.

Reservations can be useful when _bursty_ traffic, such as vMotion or full host evacuation, might impact vSAN traffic.
Reservations are only invoked if there is contention for network bandwidth. One disadvantage with reservations in
Network I/O Control is that unused reservation bandwidth cannot be allocated to virtual machine traffic. The total
bandwidth reserved among all system traffic types cannot exceed 75 percent of the bandwidth provided by the physical
network adapter with the lowest capacity.

vSAN **best practices for reservations** . Traffic reserved for vSAN cannot be allocated to virtual machine traffic, so avoid
using NIOC reservations in vSAN environments.

Setting **shares** makes a certain bandwidth available to vSAN when the physical adapter assigned for vSAN becomes
saturated. This prevents vSAN from consuming the entire capacity of the physical adapter during rebuild and
synchronization operations. For example, the physical adapter might become saturated when another physical adapter
in the team fails and all traffic in the port group is transferred to the remaining adapters in the team. The **shares** option
ensures that no other traffic impacts the vSAN network.

vSAN **recommendation on shares** . This is the fairest bandwidth allocation technique in NIOC, and is preferred for use in
vSAN environments.

Setting **limits** defines the maximum bandwidth that a certain traffic type can consume on an adapter. If no one else is
using the additional bandwidth, the traffic type with the limit also cannot consume it.

vSAN **recommendation on limits** . As traffic types with limits cannot consume additional bandwidth, avoid using NIOC
limits in vSAN environments.


**Network Resource Pools**

You can view all system traffic types that can be controlled with Network I/O Control. If you have multiple virtual machine
networks, you can assign certain bandwidth to virtual machine traffic. Use network resource pools to consume parts of
that bandwidth based on the virtual machine port group.


**Enabling Network I/O Control**

You can enable Network I/O Control in the configuration properties of the vDS. Right-click the vDS in the vSphere Client,
and choose menu **Settings > Edit Settings** .

**Note:** Network I/O Control is only available on vSphere distributed switches, not on standard vSwitches.

You can use Network I/O Control to reserve bandwidth for network traffic based on the capacity of the physical adapters
on a host. For example, if vSAN traffic uses 10 GbE physical network adapters, and those adapters are shared with other
system traffic types, you can use vSphere Network I/O Control to guarantee a certain amount of bandwidth for vSAN. This
can be useful when traffic such as vSphere vMotion, vSphere HA, and virtual machine traffic share the same physical NIC
as the vSAN network.


**Network I/O Control Configuration Example**

You can configure Network I/O Control for a vSAN cluster.

Consider a vSAN cluster with a single 10 GbE physical adapter. This NIC handles traffic for vSAN, vSphere vMotion, and
VMs. To change the shares value for a traffic type, select that traffic type from the System Traffic view ( **VDS > Configure**


VMware by Broadcom 1630


VMware Cloud Foundation 9.0


**> Resource Allocation > System Traffic** ), and click **Edit** . The shares value for vSAN traffic has been changed from the
default of Normal/50 to High/100.

Edit the other traffic types to match the share values shown in the table.

|Table 829: Sample NIOC Settings|Col2|Col3|
|---|---|---|
|**Traffic Type**|**Shares**|**Value**|
|**vSAN**|High|100|
|**vSphere vMotion**|Low|25|
|**Virtual machine**|Normal|50|
|**iSCSI/NFS**|Low|25|



For example. if a 10GbE adapter is saturated, Network I/O Control allocates 5 GbEs to vSAN on the physical adapter,
3.5 GbEs to virtual machine traffic, and 1.5 GbEs to vMotion. Use these values as a starting point to configure NIOC
configuration on your vSAN network. Ensure that vSAN has the highest priority of any protocol.

[For more details about the various parameters for bandwidth allocation, see the vSphere Networking guide.](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/vsphere-networking.html)

With each of the vSphere editions for vSAN, VMware provides a vSphere Distributed Switch as part of the edition.
Network I/O Control can be configured with any vSAN edition.

### **Understanding vSAN Network Topologies**

vSAN architecture supports different network topologies. These topologies impact on the overall deployment and
management of vSAN.

The introduction of unicast support in vSAN simplifies the network design.


**Standard Deployments**

vSAN supports several single-site deployment types.


**Layer-2, Single Site, Single Rack**

This network topology is responsible for forwarding packets through intermediate Layer 2 devices such as hosts, bridges,
or switches.

Layer 2 implementations are simplified even further and introduces unicast support. IGMP Snooping is not required.


VMware by Broadcom 1631


VMware Cloud Foundation 9.0


**Layer 2, Single Site, Multiple Racks**

This network topology works with the Layer 2 implementation where there are multiple racks, and multiple top-of-rack
switches, or TORs, connected to a core switch.


VMware by Broadcom 1632


VMware Cloud Foundation 9.0


**Layer 3, Single Site, Multiple Racks**

This network topology works for vSAN deployments where Layer 3 is used to route vSAN traffic.

This simple Layer 3 network topology uses multiple racks in the same data center, each with its own TOR switch. Route
the vSAN network between the different racks over L3, to allow all the hosts in the vSAN cluster to communicate. Place
the vSAN VMkernel ports on different subnets or VLANs, and use a separate subnet or VLAN for each rack.

This network topology routes packets through intermediate Layer 3 capable devices, such as routers and Layer 3 capable
switches. Whenever hosts are deployed across different Layer 3 network segments, the result is a routed network
topology.


VMware by Broadcom 1633


VMware Cloud Foundation 9.0


**vSAN Stretched Cluster Deployments**

vSAN supports stretched cluster deployments that span two locations.


**Supported vSAN Stretched Cluster Configurations**

vSAN supports stretched cluster configurations.

The following configuration prevent traffic from Site 1 being routed to Site 2 through the witness host, in the event of a
failure on either of the data sites' network. This configuration avoids performance degradation. To ensure that data traffic
is not switched through the witness host, use the following network topology.

Between Site 1 and Site 2, implement a stretched Layer 2 switched configuration or a Layer 3 routed configuration. Both
configurations are supported. VMware recommends Layer 3 for fault isolation and easier troubleshooting

Between Site 1 and the witness host, implement a Layer 3 routed configuration.

Between Site 2 and the witness host, implement a Layer 3 routed configuration.

We shall examine a stretched Layer 2 network between the data sites and a Layer 3 routed network to the witness site. To
demonstrate a combination of Layer 2 and Layer 3 as simply as possible, use a combination of switches and routers in the
topologies.


**Stretched Layer 2 Between Data Sites, Layer 3 to Witness Host**

vSAN supports stretched Layer 2 configurations between data sites.


VMware by Broadcom 1634


VMware Cloud Foundation 9.0


**Layer 3 Everywhere**

In this vSAN stretched cluster configuration, the data traffic is routed between the data sites and the witness host.

To implement Layer 3 everywhere as simply as possible, use routers or routing switches in the topologies.

vSAN does not require IGMP snooping or PIM because all the routed traffic is unicast.


VMware by Broadcom 1635


VMware Cloud Foundation 9.0


**Note:**

You can configure a vSAN stretched cluster in a Layer 2 network, but this configuration is not recommended.


**Separating Witness Traffic on vSAN Stretched Clusters**

vSAN supports separating witness traffic on stretched clusters.

You can separate witness traffic from vSAN traffic in two-node configurations. This means that the two vSAN hosts can be
directly connected without a 10 GbE switch.

This witness traffic separation is only supported on two-node deployments in vSAN. Separating the witness traffic on
vSAN stretched clusters is supported in vSAN.


**Two Node vSAN Deployments**

vSAN supports two-node deployments. Two-node vSAN deployments are typically used for remote offices/branch offices
(ROBO) that have a small number of workloads, but require high availability.

vSAN two-node deployments use a third witness host, which can be located remotely from the branch office. Often the
witness is maintained in the branch office, along with the management components, such as the vCenter.


**Two Node Deployments**

vSAN supports two-node deployments.


VMware by Broadcom 1636


VMware Cloud Foundation 9.0


With vSAN, the two-node vSAN implementation is much simpler. vSAN allows the two hosts at the data site to be directly
connected.


To enable this functionality, the witness traffic is separated completely from the vSAN data traffic. The vSAN data traffic
can flow between the two nodes on the direct connect, while the witness traffic can be routed to the witness site over the
management network.

The witness appliance can be located remotely from the branch office. For example, the witness might be running back
in the main data center, alongside the management infrastructure (vCenter, vROps, Log Insight, and so on). Another
supported place where the witness can reside remotely from the branch office is in vCloud Air.

Multiple remote office/branch office two-node deployments are supported on shared witness.


**Common Considerations for Two Node vSAN Deployments**

Two-node vSAN deployments provide support to other topologies. This section describes common configurations.

**Note:**

vSAN requires a minimum 1500 MTU between the witness host and data hosts and the MTUs on the witness and data
hosts must match.

For more information about two-node configurations and detailed deployment considerations outside of network, see the
vSAN core documentation.


VMware by Broadcom 1637


VMware Cloud Foundation 9.0


**Running the Witness on Another Two Node vSAN Cluster**

vSAN does not support cross hosting the witness on another two-node cluster.


**Witness Running on Another Standard vSAN Deployment**

vSAN supports witness running on another standard vSAN deployment.

This configuration is supported. Any failure on the two-node vSAN at the remote site does not impact the availability of the
standard vSAN environment at the main data center.


**Configuration of Network from Data Sites to Witness Host**

The host interfaces in the data sites communicate to the witness host over the vSAN network. There are different
configuration options available.

This topic discusses how to implement these configurations. It addresses how the interfaces on the hosts in the data sites,
which communicate to each other over the vSAN network, communicate with the witness host.


**Option 1: Physical ESXi Witness Connected over L3 with Static Routes**

The data sites can be connected over a stretched L2 network. Use this also for the data sites’ management network,
vSAN network, vMotion network, and virtual machine network.

The physical network router in this network infrastructure does not automatically transfer traffic from the hosts in the data
sites (site 1 and site 2) to the host in the witness site (site 3). To configure the vSAN stretched cluster successfully, all
hosts in the cluster must communicate. It is possible to deploy a vSAN stretched cluster in this environment.

The solution is to use _static routes_ configured on the ESXi hosts, so that the vSAN traffic from site1 and site 2 can reach
the witness host in site 3. In the case of the ESXi hosts on the data sites, add a static route to the vSAN interface, which
redirects traffic to the witness host on site 3 over a specified gateway for that network. In the case of the witness host,
the vSAN interface must have a static route added, which redirects vSAN traffic destined for the hosts in the data sites.
Use the following command to add a static route on each ESXi host in the vSAN stretched cluster: `esxcli network ip`
`route ipv4 add -g` _<gateway>_ `-n` _<network>_

**Note:**

The vCenter must be able to manage the ESXi hosts at both the data sites and the witness site. As long as there is direct
connectivity from the witness host to vCenter, there are no additional concerns regarding the management network.

There is no need to configure a vMotion network or a VM network, or add any static routes for these networks in the
context of a vSAN stretched cluster. VMs are never migrated or deployed to the vSAN witness host. Its purpose is to
maintain witness objects only, and does not require either of these networks for this task.


VMware by Broadcom 1638


VMware Cloud Foundation 9.0


**Option 2: Virtual ESXi Witness Appliance Connected over L3 with Static Routes**

Since the witness host is a virtual machine that gets deployed on a physical ESXi host, which is not part of the vSAN
cluster, that physical ESXi host must have a minimum of one VM network pre-configured. This VM network must reach
both the management network and the vSAN network shared by the ESXi hosts on the data sites.

**Note:** The witness host does not need to be a dedicated host. It can be used for many other VM workloads, while
simultaneously hosting the witness.

An alternative option is to have two preconfigured VM networks on the underlying physical ESXi host, one for the
management network and one for the vSAN network. When the virtual ESXi witness is deployed on this physical ESXi
host, the network needs to be attached and configured accordingly.

Once you have deployed the virtual ESXi witness host, configure the static route. Assume that the data sites are
connected over a stretched L2 network. Use this also for the data sites’ management network, vSAN network, vMotion
network, and virtual machine network. vSAN traffic is not routed from the hosts in the data sites (site 1 and site 2) to the
host in the witness site (site 3) over the default gateway. To configure the vSAN stretched cluster successfully, all hosts in
the cluster require static routes, so that the vSAN traffic from site 1 and site 2 can reach the witness host in site 3. Use the
`esxcli network ip route` command to add a static route on each ESXi host.


**Corner Case Deployments**

It is possible to deploy vSAN in unusual, or corner-case configurations.

These unusual topologies require special considerations.


**Three Locations and No vSAN Stretched Cluster**

You can deploy vSAN across multiple rooms, buildings or sites, rather than deploy a stretched cluster configuration.

This configuration is supported. The one requirement is that the latency between the sites must be at the same level as
the latency expected for a normal vSAN deployment in the same data center. The latency must be **<1ms** between all
hosts. If latency is greater than this value, consider a vSAN stretched cluster which tolerates latency of 5ms RTT.

For best results, maintain a uniform configuration across all sites in such a topology. To maintain availability of VMs,
configure fault domains, where the hosts in each room, building, or site are placed in the same fault domain. Avoid
asymmetric partitioning of the cluster, where host A cannot communicate to host B, but host B can communicate to host A.


**Two-Node Deployed as 1+1+Witness Stretched Cluster**

You can deploy a two-node configuration as a vSAN stretched cluster configuration, placing each host in different rooms,
buildings, or sites.

Attempt to increase the number of hosts at each site fail with an error related to licensing. For any cluster that is larger
than two hosts and that uses the dedicated witness appliance/host feature (N+N+Witness, where N > 1), the configuration
is considered a vSAN stretched cluster.

### **Troubleshooting the vSAN Network**

vSAN allows you to examine and troubleshoot the different types of issues that arise from a misconfigured vSAN network.

vSAN operations depend on the network configuration, reliability, and performance. Many support requests stem from an
incorrect network configuration, or the network not performing as expected.

Use the vSAN health service to resolve network issues. Network health checks can direct you to an appropriate
knowledge base article, depending on the results of the health check. The knowledge base article provides instructions to
solve the network problem.


VMware by Broadcom 1639


VMware Cloud Foundation 9.0


**Network Health Checks**

The health service includes a category for networking health checks.

Each health check has an **Ask Broadcom** link. If a health check fails, click **Ask Broadcom** and read the associated
Broadcom knowledge base article for further details, and guidance on how to address the issue at hand.

The following networking health checks provide useful information about your vSAN environment.

- vSAN **: Basic (unicast) connectivity check** . This check verifies that IP connectivity exists among all ESXi hosts in the
vSAN cluster, by pinging each ESXi host on the vSAN network from each other ESXi host.

- **vMotion: Basic (unicast) connectivity check** . This check verifies that IP connectivity exists among all ESXi hosts in
the vSAN cluster that have vMotion configured. Each ESXi host on the vMotion network pings all other ESXi hosts.

- **All hosts have a vSAN vmknic configured** . This check ensures each ESXi host in the vSAN cluster has a VMkernel
NIC configured for vSAN traffic.

- **All hosts have matching subnets** . This check tests that all ESXi hosts in a vSAN cluster have been configured so
that all vSAN VMkernel NICs are on the same IP subnet.

- **Hosts disconnected from VC** . This check verifies that the vCenter has an active connection to all ESXi hosts in the
vSAN cluster.

- **Hosts with connectivity issues** . This check refers to situations where vCenter lists the host as connected, but API
calls from vCenter to the host are failing. It can highlight connectivity issues between a host and the vCenter.

- **Network latency** . This check performs a network latency check of vSAN hosts. If the threshold exceeds 5 ms, a
warning is displayed.

- **vMotion: MTU checks (ping with large packet size)** . This check complements the basic vMotion ping connectivity
check. Maximum Transmission Unit size is increased to improve network performance. Incorrectly configured MTUs
might not appear as a network configuration issue, but can cause performance issues.

- **vSAN cluster partition** . This health check examines the cluster to see how many partitions exist. It displays an error if
there is more than a single partition in the vSAN cluster.


**Commands to Check the Network**

When the vSAN network has been configured, use these commands to check its state. You can check which VMkernel
Adapter (vmknic) is used for vSAN, and what attributes it contains.

Use ESXCLI to verify that the network is fully functional, and to troubleshoot any network issues with vSAN.

You can verify that the vmknic used for the vSAN network is uniformly configured correctly across all hosts, and verify that
hosts participating in the vSAN cluster can successfully communicate with one another.


**esxcli vsan network list**

This command enables you to identify the VMkernel interface used by the vSAN network.

The output below shows that the vSAN network is using vmk1. This command continues to work even if vSAN has been
turned off and the hosts no longer participate in vSAN.
```
 [root@esxi-dell-m:~] esxcli vsan network list
 Interface
 VmkNic Name: vmk1
 IP Protocol: IP
 Interface UUID: 32efc758-9ca0-57b9-c7e3-246e962c24d0
 Agent Group Multicast Address: 224.2.3.4
 Agent Group IPv6 Multicast Address: ff19::2:3:4
 Agent Group Multicast Port: 23451
 Master Group Multicast Address: 224.1.2.3
 Master Group IPv6 Multicast Address: ff19::1:2:3

```

VMware by Broadcom 1640


VMware Cloud Foundation 9.0

```
 Master Group Multicast Port: 12345
 Host Unicast Channel Bound Port: 12321
 Multicast TTL: 5
 Traffic Type: vsan
```

This provides useful information, such as which VMkernel interface is being used for vSAN traffic. In this case, it is **vmk1** .
Port 23451 is used for the heartbeat, sent every second by the primary, and is visible on every other host in the cluster.
Port 12345 is used for the CMMDS updates between the primary and backup. vSAN no longer supports multicast for any
network communication.


**esxcli network ip interface list**

This command enables you to verify items such as vSwitch or distributed switch.

Use this command to check which vSwitch or distributed switch that it is attached to, and the MTU size, which can be
useful if jumbo frames have been configured in the environment. In this case, MTU is at the default of 1500.
```
 [root@esxi-dell-m:~] esxcli network ip interface list
 vmk0
 Name: vmk0
 <<truncated>>
 vmk1
 Name: vmk1
 MAC Address: 00:50:56:69:96:f0
 Enabled: true
 Portset: DvsPortset-0
 Portgroup: N/A
 Netstack Instance: defaultTcpipStack
 VDS Name: vDS
 VDS UUID: 50 1e 5b ad e3 b4 af 25-18 f3 1c 4c fa 98 3d bb
 VDS Port: 16
 VDS Connection: 1123658315
 Opaque Network ID: N/A
 Opaque Network Type: N/A
 External ID: N/A
 MTU: 9000
 TSO MSS: 65535
 Port ID: 50331814
```

The Maximum Transmission Unit size is shown as 9000, so this VMkernel port is configured for jumbo frames, which
require an MTU of about 9,000. VMware does not make any recommendation around the use of jumbo frames. However,
jumbo frames are supported for use with vSAN.


**esxcli network ip interface ipv4 get –i vmk1**

This command displays information such as IP address and netmask of the vSAN VMkernel interface.

With this information, an administrator can now begin to use other commands available at the command line to check that
the vSAN network is working correctly.
```
 [root@esxi-dell-m:~] esxcli network ip interface ipv4 get -i vmk1
 Name IPv4 Address IPv4 Netmask  IPv4 Broadcast Address Type Gateway DHCP DNS
 ---- ------------ ------------- -------------- ------------ ------- ------- vmk1 172.40.0.9  255.255.255.0  172.40.0.255  STATIC     0.0.0.0 false

```

VMware by Broadcom 1641


VMware Cloud Foundation 9.0


**vmkping**

The `vmkping` command verifies whether all the other ESXi hosts on the network are responding to your ping requests.
```
 ~ # vmkping -I vmk2 172.32.0.3 -s 1472 -d
 PING 172.32.0.3 (172.32.0.3): 56 data bytes
 64 bytes from 172.32.0.3: icmp_seq=0 ttl=64 time=0.186 ms
 64 bytes from 172.32.0.3: icmp_seq=1 ttl=64 time=2.690 ms
 64 bytes from 172.32.0.3: icmp_seq=2 ttl=64 time=0.139 ms

 --- 172.32.0.3 ping statistics -- 3 packets transmitted, 3 packets received, 0% packet loss
 round-trip min/avg/max = 0.139/1.005/2.690 ms
```

While it does not verify multicast functionality, it can help identify a rogue ESXi host that has network issues. You can also
examine the response times to see if there is any abnormal latency on the vSAN network.

If jumbo frames are configured, this command does not report any issues if the jumbo frame MTU size is incorrect. By
default, this command uses an MTU size of 1500. If there is a need to verify if jumbo frames are successfully working endto-end, use vmkping with a larger packet size (-s) option as follows:
```
 ~ # vmkping -I vmk2 172.32.0.3 -s 8972 -d
 PING 172.32.0.3 (172.32.0.3): 8972 data bytes
 9008 bytes from 172.32.0.3: icmp_seq=0 ttl=64 time=0.554 ms
 9008 bytes from 172.32.0.3: icmp_seq=1 ttl=64 time=0.638 ms
 9008 bytes from 172.32.0.3: icmp_seq=2 ttl=64 time=0.533 ms

 --- 172.32.0.3 ping statistics -- 3 packets transmitted, 3 packets received, 0% packet loss
 round-trip min/avg/max = 0.533/0.575/0.638 ms
 ~ #
```

Consider adding -d to the vmkping command to test if packets can be sent without fragmentation.


**esxcli network ip neighbor list**

This command helps to verify if all vSAN hosts are on the same network segment.

In this configuration, we have a four-host cluster, and this command returns the ARP (Address Resolution Protocol)
entries of the other three hosts, including their IP addresses and their vmknic (vSAN is configured to use vmk1 on all
hosts in this cluster).
```
 [root@esxi-dell-m:~] esxcli network ip neighbor list -i vmk1
 Neighbor   Mac Address    Vmknic  Expiry State Type
 ----------- ----------------- ------ ------- ----- ------ 172.40.0.12 00:50:56:61:ce:22 vmk1  164 sec     Unknown
 172.40.0.10 00:50:56:67:1d:b2 vmk1  338 sec     Unknown
 172.40.0.11 00:50:56:6c:fe:c5 vmk1  162 sec     Unknown
 [root@esxi-dell-m:~]

```

**esxcli network diag ping**

This command checks for duplicates on the network, and round-trip times.

To get even more detail regarding the vSAN network connectivity between the various hosts, ESXCLI provides a powerful
network diagnostic command. Here is an example of one such output, where the VMkernel interface is on vmk1 and the
remote vSAN network IP of another host on the network is 172.40.0.10


VMware by Broadcom 1642


VMware Cloud Foundation 9.0


```
[root@esxi-dell-m:~] esxcli network diag ping -I vmk1 -H 172.40.0.10
Trace:
Received Bytes: 64
Host: 172.40.0.10
ICMP Seq: 0
TTL: 64
Round-trip Time: 1864 us
Dup: false
Detail:

Received Bytes: 64
Host: 172.40.0.10
ICMP Seq: 1
TTL: 64
Round-trip Time: 1834 us
Dup: false
Detail:

Received Bytes: 64
Host: 172.40.0.10
ICMP Seq: 2
TTL: 64
Round-trip Time: 1824 us
Dup: false
Detail:
Summary:
Host Addr: 172.40.0.10
Transmitted: 3
Recieved: 3
Duplicated: 0
Packet Lost: 0
Round-trip Min: 1824 us
Round-trip Avg: 1840 us
Round-trip Max: 1864 us
[root@esxi-dell-m:~]

```


**Checking vSAN Network Performance**

Make that there is sufficient bandwidth between your ESXi hosts. This tool can assist you in testing whether your vSAN
network is performing optimally.

To check the performance of the vSAN network, you can use `iperf` tool to measure maximum TCP bandwidth and
latency. It is located in `/usr/lib/vmware/vsan/bin/iperf.copy.` Run it with `-–help` to see the various options.
Use this tool to check network bandwidth and latency between ESXi hosts participating in a vSAN cluster.

[Broadcom knowledge base article 2001003 can assist with setup and testing.](https://knowledge.broadcom.com/external/article?legacyId=2001003)

This is most useful when a vSAN cluster is being commissioned. Running **iperf** tests on the vSAN network when the
cluster is already in production can impact the performance of the VMs running on the cluster.


**Checking vSAN Network Limits**

The `vsan.check.limits` command verifies that none of the vSAN thresholds are being breached.
```
 > ls

```

VMware by Broadcom 1643


VMware Cloud Foundation 9.0

```
0 /
1 vcsa-04.rainpole.com/
> cd 1
/vcsa-04.rainpole.com> ls
0 Datacenter (datacenter)
/vcsa-04.rainpole.com> cd 0
/vcsa-04.rainpole.com/Datacenter> ls
0 storage/
1 computers [host]/
2 networks [network]/
3 datastores [datastore]/
4 vms [vm]/
/vcsa-04.rainpole.com/Datacenter> cd 1
/vcsa-04.rainpole.com/Datacenter/computers> ls
0 Cluster (cluster): cpu 155 GHz, memory 400 GbE
1 esxi-dell-e.rainpole.com (standalone): cpu 38 GHz, memory 123 GbE
2 esxi-dell-f.rainpole.com (standalone): cpu 38 GHz, memory 123 GbE
3 esxi-dell-g.rainpole.com (standalone): cpu 38 GHz, memory 123 GbE
4 esxi-dell-h.rainpole.com (standalone): cpu 38 GHz, memory 123 GbE
/vcsa-04.rainpole.com/Datacenter/computers> vsan.check_limits 0
2017-03-14 16:09:32 +0000: Querying limit stats from all hosts ...
2017-03-14 16:09:34 +0000: Fetching vSAN disk info from esxi-dell-m.rainpole.com (may take a moment) ...
2017-03-14 16:09:34 +0000: Fetching vSAN disk info from esxi-dell-n.rainpole.com (may take a moment) ...
2017-03-14 16:09:34 +0000: Fetching vSAN disk info from esxi-dell-o.rainpole.com (may take a moment) ...
2017-03-14 16:09:34 +0000: Fetching vSAN disk info from esxi-dell-p.rainpole.com (may take a moment) ...
2017-03-14 16:09:39 +0000: Done fetching vSAN disk infos
+--------------------------+-------------------+-----------------------------------------------------------------+
| Host           | RDT        | Disks
|
+--------------------------+-------------------+-----------------------------------------------------------------+
| esxi-dell-m.rainpole.com | Assocs: 1309/45000 | Components: 485/9000
|
|             | Sockets: 89/10000 | naa.500a075113019b33: 0% Components: 0/0
|
|             | Clients: 136    | naa.500a075113019b37: 40% Components: 81/47661
|
|             | Owners: 138    | t10.ATA_____Micron_P420m2DMTFDGAR1T4MAX_____ 0% Components:
0/0 |
|             |          | naa.500a075113019b41: 37% Components: 80/47661
|
|             |          | naa.500a07511301a1eb: 38% Components: 81/47661
|
|             |          | naa.500a075113019b39: 39% Components: 79/47661
|
|             |          | naa.500a07511301a1ec: 41% Components: 79/47661
|
<<truncated>>

```


From a network perspective, it is the RDT associations (Assocs) and sockets count that are important. There are 45,000
associations per host in vSAN 6.0 and later. An RDT association is used to track peer-to-peer network state within vSAN.


VMware by Broadcom 1644


VMware Cloud Foundation 9.0


vSAN is sized so that it never runs out of RDT associations. vSAN also limits how many TCP sockets it is allowed to use,
and vSAN is sized so that it never runs out of its allocation of TCP sockets. There is a limit of 10,000 sockets per host.

A **vSAN client** represents object's access in the vSAN cluster. The client typically represents a virtual machine running on
a host. The client and the object might not be on the same host. There is no hard defined limit, but this metric is shown to
help understand how clients balance across hosts.

There is only one **vSAN owner** for a given vSAN object, typically co-located with the vSAN client accessing this object.
vSAN owners coordinate all access to the vSAN object and implement functionality, such as mirroring and striping. There
is no hard defined limit, but this metric is once again shown to help understand how owners balance across hosts.

### **Networking Considerations for vSAN File Service**

vSAN File Service is a layer that sits on top of vSAN to provide file shares. It currently supports SMB, NFSv3, and
NFSv4.1 file shares.

Following are the network considerations for vSAN File Service:




- You must allocate static IP addresses as file server IPs from vSAN File Service network, each IP is the access point to
vSAN file shares.

 - For best performance, the number of IP addresses must be equal to the number of hosts in the vSAN cluster.

 - All the static IP addresses should be from the same subnet.

 - Every static IP address has a corresponding FQDN, which should be part of the Forward lookup and Reverse



lookup zones in the DNS server.

- You must ensure to prepare the network as vSAN File Service network:

 - If using standard switch based network, the Promiscuous Mode and Forged Transmits are enabled as part of the



vSAN File Services enablement process.

- If using DVS based network, vSAN File Services are supported on DVS. Create a dedicated port group for vSAN



File Services in the DVS. MacLearning and Forged Transmits are enabled as part of the vSAN File Services
enablement process for a provided DVS port group.
**Note:** If using NSX-based network, ensure that MacLearning is enabled for the provided network entity from the
NSX admin console, and all the hosts and File Services nodes are connected to the desired NSX-T network.

- For SMB share and NFS share with Kerberos security, you must provide information about your AD domain and
organizational unit (optional). In addition, a user account with sufficient privileges to create and delete objects is
required.

- Ensure that the file server can access AD server and DNS server. The file server must be able to access all the ports
required by AD service.
Following are the ports that vSAN File Service uses for network connectivity. Ensure that these ports are not blocked
by the firewall.
[For more information on ports and protocols for vSAN File Service, see ports.broadcom.com.](https://ports.broadcom.com/home)


### **Networking Considerations for iSCSI on vSAN**

vSAN iSCSI target service allows hosts and physical workloads that reside outside the vSAN cluster to access the vSAN
datastore. This feature enables an iSCSI initiator on a remote host to transport block-level data to an iSCSI target on a
storage device within the vSAN cluster.

The iSCSI targets on vSAN are managed using Storage Policy Based Management (SPBM) similar to other vSAN
objects. For the iSCSI LUNs, this space savings the space through deduplication and compression, and provides security
through encryption. For enhanced security, vSAN iSCSI target service uses Challenge Handshake Authentication Protocol
(CHAP) and Mutual CHAP authentication.

vSAN identifies each iSCSI target by a unique iSCSI qualified Name (IQN). The iSCSI target is presented to a remote
iSCSI initiator using the IQN, so that the initiator can access the LUN of the target. vSAN iSCSI target service allows


VMware by Broadcom 1645


VMware Cloud Foundation 9.0


creating iSCSI initiator groups. The iSCSI initiator group restricts access to only those initiators that are members of the
group.


**Characteristics of vSAN iSCSI Network**

Following are the characteristics of a vSAN iSCSI network:

- iSCSI Routing - iSCSI initiators can make routed connections to vSAN iSCSI targets over an L3 network.

- IPv4 and IPv6 - vSAN iSCSI network supports both IPv4 and IPv6.

- IP Security - IPSec on the vSAN iSCSI network provides increased security.
**Note:**

ESXi hosts support IPsec using IPv6 only.

- Jumbo Frames - Jumbo Frames are supported on the vSAN iSCSI network.

- NIC Teaming - All NIC teaming configurations are supported on the vSAN iSCSI network.

- Multiple Connections per Session (MCS) - vSAN iSCSI implementation does not support MCS.

### **Migrating from Standard to Distributed vSwitch**

You can migrate from a vSphere Standard Switch to a vSphere Distributed Switch, and use Network I/O Control. This
enables you to prioritize the QoS (Quality of Service) on vSAN traffic.

**Warning:**

It is best to have access to the ESXi hosts, although you might not need it. If something goes wrong, you can access the
console of the ESXi hosts.

Make a note of the original vSwitch setup. In particular, note the load-balancing and NIC teaming settings on the source.
Make sure the destination configuration matches the source.


**Create a Distributed Switch**

Create the distributed vSwitch and give it a name.

1. In the vSphere Client Host and Clusters view, right-click a data center and select menu **New Distributed Switch** .
2. Enter a name.
3. Select the version of the vSphere Distributed Switch.
4. Add the settings. Determine how many uplinks you are currently using for networking. This example has six:

management, vMotion, VMs, and three for vSAN (a LAG configuration). Enter 6 for the number of uplinks. Your
environment might be different, but you can edit it later.
You can create a default port group at this point, but additional port groups are needed.
5. Finish the configuration of the distributed vSwitch.

The next step is to configure and create the additional port groups.


**Create Port Groups**

A single default port group was created for the management network. Edit this port group to make sure it has all the
characteristics of the management port group on the standard vSwitch, such as VLAN and NIC teaming, and failover
settings.

Configure the management port group.

1. In the vSphere Client Networking view, select the distributed port group, and click **Edit** .
2. For some port groups, you must change the VLAN. Since VLAN 51 is the management VLAN, tag the distributed port

group accordingly.


VMware by Broadcom 1646


VMware Cloud Foundation 9.0


3. Click **OK** .

Create distributed port groups for vMotion, virtual machine networking, and vSAN networking.

1. Right-click the vSphere Distributed Switch and select menu **Distributed Port Group > New Distributed Port Group** .
2. For this example, create a port group for the vMotion network.

Create all the distributed port groups on the distributed vSwitch. Then migrate the uplinks, VMkernel networking, and
virtual machine networking to the distributed vSwitch and associated distributed port groups.

**Warning:** Migrate the uplinks and networks in step-by-step fashion to proceed smoothly and with caution.


**Migrate Management Network**

Migrate the management network (vmk0) and its associated uplink (vmnic0) from the standard vSwitch to the distributed
vSwitch (vDS).



1. Add hosts to the vDS.



a. Right-click the vDS and select menu **Add and Manage Hosts** .
b. Add hosts to the vDS. Click the green Add icon (+), and add all hosts from the cluster.
2. Configure the physical adapters and VMkernel adapters.



a. Click **Manage physical adapters** to migrate the physical adapters and VMkernel adapters, vmnic0 and vmk0 to



the vDS.
b. Select an appropriate uplink on the vDS for physical adapter vmnic0. For this example, use Uplink1. The physical



adapter is selected and an uplink is chosen.
3. Migrate the management network on vmk0 from the standard vSwitch to the distributed vSwitch. Perform these steps



on each host.
a. Select vmk0, and click **Assign port group** .
b. Assign the distributed port group created for the management network earlier.
4. Finish the configuration.



a. Review the changes to ensure that you are adding four hosts, four uplinks (vmnic0 from each host), and four



VMkernel adapters (vmk0 from each host).
b. Click **Finish** .



When you examine the networking configuration of each host, review the switch settings, with one uplink (vmnic0) and the
vmk0 management port on each host.

Repeat this process for the other networks.


**Migrate vMotion**

To migrate the vMotion network, use the same steps used for the management network.

Before you begin, ensure that the distributed port group for the vMotion network has the same attributes as the port group
on the standard vSwitch. Then migrate the uplink used for vMotion (vmnic1), with the VMkernel adapter (vmk1).


**Migrate vSAN Network**

If you have a single uplink for the vSAN network, then use the same process as before. However, if you are using more
than one uplink, there are additional steps.

If the vSAN network is using Link Aggregation (LACP), or it is on a different VLAN to the other VMkernel networks, place
some of the uplinks into an unused state for certain VMkernel adapters.

For example, VMkernel adapter vmk2 is used for vSAN. However, uplinks vmnic3, 4 and 5 are used for vSAN and
they are in a LACP configuration. Therefore, for vmk2, all other vmnics (0, 1 and 2) must be placed in an unused state.


VMware by Broadcom 1647


VMware Cloud Foundation 9.0


Similarly, for the management adapter (vmk0) and vMotion adapter (vmk0), place the vSAN uplinks/vmnics in an unused
state.

Modify the settings of the distributed port group and change the path policy and failover settings. On the **Manage**
**physical network adapter** page, perform the steps for multiple adapters.

Assign the vSAN VMkernel adapter (vmk2) to the distributed port group for vSAN.

**Note:** If you are only now migrating the uplinks for the vSAN network, you might not be able to change the distributed
port group settings until after the migration. During this time, vSAN might have communication issues. After the migration,
move to the distributed port group settings and make any policy changes and mark any uplinks to be unused. vSAN
networking then returns to normal when this task is finished. Use the vSAN health service to verify that everything is
functional.


**Migrate VM Network**

The final task needed to migrate the network from a standard vSwitch to a distributed vSwitch is to migrate the VM
network.

Manage host networking.



1. Right-click the vDS and choose menu **Add and Manage Hosts** .
2. Select all the hosts in the cluster, to migrate virtual machine networking for all hosts to the distributed vSwitch.



Do not move any uplinks. However, if the VM networking on your hosts used a different uplink, then migrate the uplink
from the standard vSwitch.
3. Select the VMs to migrate from a virtual machine network on the standard vSwitch to the virtual machine distributed



port group on the distributed vSwitch. Click **Assign port group**, and select the distributed port group.
4. Review the changes and click **Finish** . In this example, you are moving to VMs. Any templates using the original



standard vSwitch virtual machine network must be converted to VMs, and edited. The new distributed port group for
VMs must be selected as the network. This step cannot be achieved through the migration wizard.



Since the standard vSwitch no longer has any uplinks or port groups, it can be safely removed.

This completes the migration from a vSphere Standard Switch to a vSphere Distributed Switch.

### **Checklist Summary for vSAN Network**

Use the checklist summary to verify your vSAN network requirements.

- Check if you use shared 10 GbE NIC or dedicated 1GbE NIC. All-flash clusters require 10 GbE NICs.

- Verify that redundant NIC teaming connections are configured.

- Verify that flow control is enabled on the ESXi host NICs.

- Verify that VMkernel port for vSAN network traffic is configured on each host.

- Verify that you have identical VLAN, MTU and subnet across all interfaces.

- Verify that you can run `vmkping` successfully between all hosts. Use the health service to verify.

- If you use jumbo frames, verify that you can run `vmkping` successfully with 9000 packet size between all hosts. Use
the health service to verify.

- Ensure that the physical switch can meet vSAN requirements (flow control and feature interoperability).

- Verify that the network does not have performance issues, such as excessive dropped packets or pause frames.

- Verify that network limits are within acceptable margins.

- Test vSAN network performance with `iperf`, and verify that it meets expectations.


VMware by Broadcom 1648


VMware Cloud Foundation 9.0
## **Planning and Configuring vSAN**

_Planning and Configuring vSAN_ describes how to design and configure a VMware [®] vSAN [™] cluster in a vSphere
environment. The information includes system requirements, sizing guidelines, and suggested best practices.


**Intended Audience**

This guide is intended for anyone who wants to design and configure a vSAN cluster in a VMware vSphere environment.
The information in this manual is written for experienced system administrators who are familiar with virtual machine (VM)
technology and virtual datacenter operations. This manual assumes familiarity with VMware vSphere, including VMware
ESXi, vCenter and the vSphere Client.

- For more information about network requirements and network design, see the Designing vSAN Network guide.

- For more information about vSAN features and how to configure a vSAN cluster, see the Administering VMware vSAN
guide.

- For more information about monitoring a vSAN cluster and fixing problems, see the Monitoring and Troubleshooting
vSAN guide.
### **What is vSAN**

VMware vSAN is a software-defined, enterprise storage solution that supports hyper-converged infrastructure (HCI)
systems.

vSAN aggregates local or direct-attached capacity devices of all ESXi hosts in a cluster and creates a single storage pool
shared across all ESXi hosts in the vSAN cluster. While supporting vSphere features that require shared storage, such as
High Availability (HA), vMotion, and Distributed Resource Scheduler (DRS), vSAN eliminates the need for external shared
storage and simplifies storage configuration and VM provisioning activities.


**vSAN Concepts**

VMware vSAN is an easy to manage, object-based enterprise software distributed storage (SDS) system designed to
leverage the capabilities of modern hardware.

vSAN pools disk space from multiple ESXi hosts in a cluster to create a single shared datastore. You can configure vSAN
to work as either a hybrid or all-flash cluster. In hybrid clusters, flash devices are used for the cache layer and magnetic
disks are used for the storage capacity layer. In all-flash clusters, flash devices are used for both cache and capacity.

You can turn on vSAN on existing vSphere clusters, or when you create a new cluster. vSAN aggregates the storage
capacity of eligible devices from multiple ESXi hosts in a cluster into a single, shared datastore. Expanding capacity in
vSAN is simple and can be done by the following:

- Expand storage capacity only: Add storage devices to existing ESXi hosts in the vSAN cluster.

- Expand compute capacity only: Add new ESXi hosts without local storage devices to the existing vSAN cluster.

- Expand compute and storage capacity: Add new ESXi hosts with local storage to the existing vSAN cluster.

vSAN works best when all ESXi hosts in the vSphere cluster share similar or identical configurations across all cluster
members, including similar or identical storage configurations. ESXi hosts without any local devices also can participate
and run their VMs on the vSAN datastore.

With the availability of vSAN Express Storage Architecture (ESA), all storage devices claimed by vSAN contribute to
capacity and performance. Each ESXi host's storage devices claimed by vSAN form a storage pool. The storage pool
represents the amount of caching and capacity provided by the ESXi host to the vSAN datastore.

vSAN storage cluster is a disaggregated storage solution available with vSAN ESA. It pools storage devices across
dedicated ESXi hosts, separating storage resources from compute hosts.

For vSAN Original Storage Architecture (OSA), each ESXi host that contributes storage devices to the vSAN datastore
must provide at least one device for flash cache and at least one device for capacity. The devices on the contributing ESXi


VMware by Broadcom 1649


VMware Cloud Foundation 9.0


host form one or more disk groups. Each disk group contains one flash cache device, and one or more capacity devices
for persistent storage. Each ESXi host can be configured to use multiple disk groups.

vSAN ESA also provides performance, efficiency, and scalability improvements. The hardware requirements for vSAN
[ESA is different from vSAN OSA. For more information on vSAN ESA and vSAN OSA, see Comparing vSAN OSA to](https://blogs.vmware.com/cloud-foundation/2022/08/31/comparing-the-original-storage-architecture-to-the-vsan-8-express-storage-architecture/)
[vSAN ESA.](https://blogs.vmware.com/cloud-foundation/2022/08/31/comparing-the-original-storage-architecture-to-the-vsan-8-express-storage-architecture/)

vSAN storage cluster is a distributed storage system that provides vSAN ESA capabilities while functioning as a storage[only cluster. For more information, see Introducing vSAN Storage Cluster.](https://blogs.vmware.com/cloud-foundation/2023/08/22/introducing-vsan-max/)

For best practices, capacity considerations, and general recommendations about designing and sizing a vSAN cluster,
[see the VMware vSAN Design Guide.](https://www.vmware.com/docs/vmware-vsan-design-guide)


**Characteristics of vSAN**


The following characteristics apply to vSAN, its clusters, and datastores.

vSAN includes features to add resiliency and efficiency to your data computing and storage environment.


**Table 830: vSAN Features**







|Supported Features|Description|
|---|---|
|Shared storage support|vSAN supports vSphere features that require shared storage, such as HA,<br>vMotion, and DRS. For example, if a ESXi host becomes overloaded, DRS<br>can migrate VMs to other ESXi hosts in the cluster.|
|On-disk format|vSAN on-disk virtual file format provides highly scalable snapshot and<br>clone management support per vSAN ESA cluster. For information about<br>the number of VM snapshots and clones supported per vSAN cluster, see<br>thevSphere Configuration Maximums guide.|
|All-flash configurations|vSAN can be configured for all-flash cluster.|
|Fault domains|vSAN supports configuring fault domains or rack awareness to protect ESXi<br>hosts from rack or chassis failures when the vSAN cluster spans across<br>multiple racks or blade server chassis in a data center.|
|File service|vSAN file service enables you to create file shares in the vSAN datastore<br>that client workstations or VMs can access.|
|iSCSI target service|vSAN iSCSI target service enables ESXi hosts and physical workloads that<br>reside outside the vSAN cluster to access the vSAN datastore.|
|vSAN Stretched clusters|vSAN supports stretched clusters that span across two availability zones.|
|Remote Branch Office (ROBO) or Two node vSAN<br>clusters|vSAN supports two node clusters that consists of two ESXi hosts and<br>a witness host. This configuration is ideal for environments with limited<br>resources, such as remote or branch offices.|
|Support for Windows Server Failover Clusters (WSFC)|vSAN support SCSI-3 Persistent Reservations (SCSI-3 PR) on a virtual<br>disk level required by WSFC to arbitrate access to a shared disk between<br>nodes. Support of SCSI-3 PRs enables configuration of WSFC with a disk<br>resource shared between VMs natively on vSAN datastores.<br>Currently the following configurations are supported:<br>•<br>Up to 6 application nodes per cluster.<br>•<br>Up to 64 shared virtual disks per node.<br>For more information on the supported versions, seeWindows Server<br>Release Information.|


VMware by Broadcom 1650


VMware Cloud Foundation 9.0







|Supported Features|Description|
|---|---|
|vSAN Skyline health service|vSAN Skyline health service includes preconfigured health check tests to<br>monitor, troubleshoot, diagnose the cause of cluster component problems,<br>and identify any potential risk.|
|vSAN performance service|vSAN performance service includes statistical charts used to monitor IOPS,<br>throughput, latency, and congestion. You can monitor performance of a<br>vSAN cluster, ESXi host, disk group, disk, and VMs.|
|Integration with vSphere storage features|vSAN integrates with vSphere data management features traditionally used<br>with VMFS and NFS storage. These features include snapshots, linked<br>clones, and vSphere Replication.|
|Storage Policy Based Management for Virtual Machine<br>Storage|vSAN works with VM storage policies that control the type of storage<br>provided for the VM, the placement of the VM within storage, and the data<br>services the VM uses.<br>If you do not assign a storage policy to the VM during deployment, the<br>vSAN Default Storage Policy is automatically assigned to the VM.|
|Rapid provisioning|vSAN rapid provisioning simplifies storage management by enabling rapid<br>storage creation and deployment within vCenter, as part of VM creation<br>and deployment. vSAN through its distributed shared storage, streamlines<br>storage allocation for VMs, allowing storage provisioning without the need<br>for manual allocation or pre-provisioning of storage. For more information,<br>seevSAN Space Efficiency Technologies.|
|Space Efficency: Compression|vSAN ESA enables compression by default using the vSAN storage policy.<br>The data compression occurs at the top of the vSAN stack. By handling<br>compression at this level, vSAN ESA eliminates the need to compress the<br>data on other ESXi hosts with object copies. This reduces the amount of<br>data transmitted over the network.<br>You can use the Compression-only setting for vSAN OSA clusters with<br>demanding workloads that cannot take advantage of deduplication<br>techniques.|
|Space Efficiency: Deduplication|When using vSAN OSA, you can enable deduplication and compression.<br>Deduplication is enabled at the cluster level and the data is destaged to the<br>capacity tier. The data in the disk group initially goes through deduplication<br>followed by compression.<br>**Note:**<br>Deduplication is not available in the vSAN ESA cluster.|
|Space Efficently: Trim and Unmap|vSAN has full awareness of TRIM/UNMAP commands sent from the guest<br>operating system and can reclaim the previously allocated storage as free<br>space. You can enable Trim and Unmap on vSAN OSA, but gets enabled<br>by default on vSAN ESA.|
|Data-at-rest encryption|vSAN provides data-at-rest encryption. In vSAN ESA, the data is encrypted<br>in the upper layers of vSAN and it receives incoming writes. The data goes<br>through compression before it is encrypted resulting in lower overhead or<br>latency. All the vSAN traffic transmitted across hosts are encrypted.<br>In vSAN OSA, the data is encrypted after all other processing, such as<br>deduplication, is performed. Data-at-rest encryption protects data on<br>storage devices, in case a device is removed from the cluster.<br>**Note:**<br>Ensure that you have a key management server to perform data-at-rest<br>encryption.|


VMware by Broadcom 1651


VMware Cloud Foundation 9.0

|Supported Features|Description|
|---|---|
|Data-in-transit encryption|vSAN can encrypt data-in-transit across ESXi hosts in the cluster. When<br>you enable data-in-transit encryption, vSAN encrypts all data and metadata<br>traffic between ESXi hosts. vSAN OSA and vSAN ESA support multiple key<br>rotation options such as Shallow and Deep Rekey, and uses AES-256 bit<br>encryption for data-in-transit.<br>**Note:**<br>You do not need a key management server to perform data-in-transit<br>encryption.|
|Cloud native storage|Cloud native storage integrates storage directly into the VMware vSphere<br>platform enabling VMs and containers to use shared storage.|
|Container storage interface|The Container storage interface (CSI) is an open standard that enables<br>container orchestration platforms like Kubernetes. It manages storage<br>resources through a consistent plugin-based architecture.|
|Data persistence platform|The vSAN Data Persistence platform provides a framework for software<br>technology partners to integrate with VMware infrastructure. Each partner<br>must develop their own plug-in for VMware customers to receive the<br>benefits of the vSAN Data Persistence platform.|
|Disaggregated HCI|The disaggregated HCI in vSAN decouples compute and storage<br>resources. It allows compute and storage resources to scale independently<br>within a VMware environment. It enables the use of dedicated storage-only<br>hosts.|
|vSAN storage clusters|vSAN storage clusters are groups of ESXi hosts that pool their local<br>storage devices to create a shared, distributed datastore managed by<br>VMware vSAN.|
|RAID5/6|RAID 5/6 in vSAN provides data protection through erasure coding. This<br>allows effecient storage utilization while maintaining fault tolerance.<br>•<br>RAID 5: Protects against one failure. The data is split into three data<br>block and one parity block. It requires a minimum of four hosts.<br>•<br>RAID 6: Protects against two simultaneous failures. The data is split<br>into four data blocks and two parity blocks. It requires a minimum of six<br>hosts.|
|SDK support|The VMware vSAN SDK is an extension of the VMware vSphere<br>Management SDK. It includes documentation, libraries and code examples<br>that help developers automate installation, configuration, monitoring, and<br>troubleshooting of vSAN.|



[For more information, see vSAN Feature Matrix.](https://www.vmware.com/docs/vmw-vsan-feature-matrix)


**vSAN Terms and Definitions**


vSAN introduces specific terms and definitions that are important to understand.

Before you get started with vSAN, review the key vSAN terms and definitions.


**Storage Pool (vSAN Express Storage Architecture)**

vSAN ESA replaces disk groups with a new logical construct called a storage pool. It organizes eligible NVMe devices into
a single storage pool that handles both caching and capacity, eliminating the need for separate cache and capacity tiers.
This single-tier design improves performance and simplifies management.


VMware by Broadcom 1652


VMware Cloud Foundation 9.0


**Disk Group (vSAN Original Storage Architecture)**

A disk group is a logical construct used to manage the relationship between the capacity devices and their cache tier.

- Each ESXi host that contributes storage in a vSAN cluster must have at least one disk group.

- A disk group contains one cache device and between one to seven capacity devices.

- An ESXi host can have up to five disk groups.

- Each disk group can include up to seven capacity devices, allowing a maximum of 35 capacity devices per host.

- The cache device must be a flash device in both hybrid and all-flash configurations.

For information about creating and managing disk groups, see Create a Disk Group or Storage Pool in vSAN Cluster.


**Consumed Capacity**

Consumed capacity is the amount of physical capacity consumed by one or more VMs at any point. Many factors
determine consumed capacity, including the consumed size of your `.vmdk` files, protection replicas, and so on. When
calculating for cache sizing, do not consider the capacity used for protection replicas.


**Object-Based Storage**

vSAN stores and manages data in the form of flexible data containers called objects. An object is a logical volume that
has its data and metadata distributed across the cluster. VMDKs, VM home namespace, VM swap areas, snapshot delta
disks, and snapshot memory maps are all examples of storage objects in vSAN. When you provision a VM on a vSAN
datastore, vSAN creates a set of objects comprised of multiple components for each virtual disk or any other data types
being stored. It also creates the VM home namespace, which is a container object that stores all metadata files of your
VM. Based on the assigned VM storage policy, vSAN provisions and manages each object individually, which might also
involve creating a RAID configuration for every object.

**Note:**

If vSAN ESA is enabled, every snapshot is not a new object. A virtual disk and its snapshots are contained in one vSAN
object.

When vSAN creates an object for a virtual disk and determines how to distribute the object in the cluster, it considers the
following factors:

- vSAN verifies that the virtual disk requirements are applied according to the specified VM storage policy settings.

- vSAN verifies that the correct cluster resources are used at the time of provisioning. For example, based on the
protection policy, vSAN determines how many replicas to create. The performance policy determines the amount of
flash read cache allocated for each replica and how many stripes to create for each replica and where to place them in
the cluster.

- vSAN continually monitors and reports the policy compliance status of the virtual disk. If you find any noncompliant
policy status, you must troubleshoot and resolve the underlying problem.
**Note:**

When required, you can edit VM storage policy settings. Changing the storage policy settings does not affect VM
access. vSAN actively throttles the storage and network resources used for reconfiguration to minimize the impact
of object reconfiguration to normal workloads. When you change VM storage policy settings, vSAN might initiate
an object recreation process and subsequent resynchronization. For more information, see About vSAN Cluster
Resynchronization.

- vSAN verifies that the required protection components, such as mirrors and witnesses, are placed on separate ESXi
hosts or fault domains. For example, to rebuild components during a failure, vSAN looks for ESXi hosts that satisfy the
placement rules where protection components of VM objects must be placed on two different ESXi hosts, or across
fault domains.


VMware by Broadcom 1653


VMware Cloud Foundation 9.0


**vSAN Datastore**

After you enable vSAN on a cluster, a single vSAN datastore is created. It appears as another type of datastore in the list
of datastores that might be available, including Virtual Volume, VMFS, and NFS. A single vSAN datastore can provide
different service levels for each VM or each virtual disk. In vCenter, storage characteristics of the vSAN datastore appear
as a set of capabilities. You can reference these capabilities when defining a storage policy for VMs. When you later
deploy VMs, vSAN uses this policy to place VMs storage objects in the optimal manner based on the requirements of
[each VM. For general information about using storage policies, see the vSphere Storage guide.](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/vsphere-storage.html)

A vSAN datastore has specific characteristics to consider.

- vSAN provides a single vSAN datastore accessible to all ESXi hosts in the cluster, whether or not they contribute
storage to the cluster. Each ESXi host can also mount any other datastores, including Virtual Volumes, VMFS, or NFS.

- You can use Storage vMotion to move VMs between vSAN datastores, NFS datastores, and VMFS datastores.

- Only magnetic disks and flash devices used for capacity can contribute to the datastore capacity. The devices used for
flash cache are not counted as part of the datastore.


**Objects and Components**

Each object is composed of a set of components, determined by capabilities that are in use in the VM storage policy.
For example, with **Failures to tolerate** set to 1, vSAN ensures that the protection components, such as replicas and
witnesses, are placed on separate ESXi hosts in the vSAN cluster, where each replica is an object component. In addition,
in the same policy, if the **Number of disk stripes per object** configured to two or more, vSAN also stripes the object
across multiple capacity devices and each stripe is considered a component of the specified object. When needed, vSAN
might also break large objects into multiple components.

A vSAN datastore contains the following object types:

**VM home namespace** The VM home directory where all VM configuration files are
stored, such as `.vmx`, log files, `.vmdk` files, and snapshot delta
description files.
**VMDK** A VM disk or `.vmdk` file that stores the contents of the VM's hard
disk drive.
**VM swap object** Created when a VM is powered on.
**Snapshot delta VMDKs** Created when VM snapshots are taken. Such delta disks are not
created for vSAN ESA.

**Memory object** Created when the snapshot memory option is selected when
creating or suspending a VM.
**vSAN durability component** Provides a mechanism to maintain the required availability for VMs
while there is an ESXi host failure or maintenance. This ensure
that vSAN still maintains the availability level specified within the
storage policy.


[For more information on vSAN objects and components, see vSAN Objects and Components Revisited.](https://blogs.vmware.com/cloud-foundation/2022/06/30/vsan-objects-and-components-revisited)


**Virtual Machine Compliance Status: Compliant and Noncompliant**

A virtual machine is considered noncompliant when one or more of its objects fail to meet the requirements of its assigned
storage policy. For example, the status might become noncompliant when one of the mirror copies is inaccessible. If your
virtual machines are in compliance with the requirements defined in the storage policy, the status of your virtual machines
is compliant. From the **Physical Disk Placement** tab on the **Virtual Disks** page, you can verify the virtual machine object
compliance status. For information about troubleshooting a vSAN cluster, see Monitor Datastore Sharing with vSphere
Client.


VMware by Broadcom 1654


VMware Cloud Foundation 9.0


**Component State: Degraded, Absent, and Out of date States**

vSAN acknowledges the following failure states for components:

- Degraded. A component is Degraded when vSAN detects a permanent component failure and determines that
the failed component cannot recover to its original working state. As a result, vSAN starts to rebuild the degraded
components immediately. This state might occur when a component is on a failed device.

- Absent. A component is Absent when vSAN detects a temporary component failure where components, including all
its data, might recover and return vSAN to its original state. This state might occur when you are restarting ESXi hosts
or if you unplug a device from a vSAN host. vSAN starts to rebuild the components in absent status after waiting for 60
minutes.

- Out of date. A component is Out of date when vSAN detects that the assigned storage policy is outdated. When you
click **Reapply VM Storage Policy**, all the objects of the VM are back to the compliant state.


**Object State: Healthy and Unhealthy**

An unhealthy object is also called as inaccessible object as these objects are virtual. vSAN cannot access these objects
as its components are no longer available. Depending on the type and number of failures in the cluster, an object might be
in one of the following states:

- Healthy. When at least one full RAID 1 mirror is available, or the minimum required number of data segments are
available, the object is considered healthy.

- Unhealthy. An object is considered unhealthy when no full mirror is available or the minimum required number of data
segments are unavailable for RAID 5 or RAID 6 objects. If fewer than 50 percent of an object's votes are available, the
object is unhealthy. Multiple failures in the cluster can cause objects to become unhealthy. When the operational status
of an object is considered unhealthy, it impacts the availability of the associated virtual machine.


**Witness**

A witness is a component that contains only metadata and does not contain any actual application data. It serves as
a tiebreaker when a decision must be made regarding the availability of the surviving datastore components, after a
potential failure. A witness consumes approximately 4 MB of space for metadata on the vSAN datastore when using ondisk format version 2.0 and later.

**Note:**

In a vSAN ESA stretched cluster or Two node vSAN cluster configuration, a witness component gets created on the
dedicated witness host.

vSAN maintains a quorum by using an asymmetrical voting system where each component might have more than one
vote to decide the availability of objects. Greater than 50 percent of the votes that make up a virtual machines storage
object must be accessible at all times for the object to be considered available. When 50 percent or fewer votes are
accessible to all hosts, the object is no longer accessible to the vSAN datastore. Inaccessible objects can impact the
availability of the associated virtual machine.


**Storage Policy-Based Management (SPBM)**

When you use vSAN, you can define virtual machine storage requirements, such as performance and availability, in the
form of a policy. vSAN ensures that the virtual machines deployed to vSAN datastores are assigned at least one virtual
machine storage policy. When you know the storage requirements of your virtual machines, you can define storage
policies and assign the policies to your virtual machines. If you do not apply a storage policy when deploying virtual
machines, vSAN automatically assigns a default vSAN storage policy with **Failures to tolerate** set to 1, a single disk
stripe for each object, and thin provisioned virtual disk. When you enable vSAN ESA Auto-Policy Management, vSAN
automatically creates an optimized, cluster-specific default storage policy that helps you to run workloads on an ESA
cluster using the optimal level of resilience and efficiency. For information about working with vSAN storage policies, see
Using vSAN Policies.


VMware by Broadcom 1655


VMware Cloud Foundation 9.0


**vSphere PowerCLI**

VMware vSphere PowerCLI adds command-line scripting support for vSAN, to help you automate configuration and
management tasks. vSphere PowerCLI provides a Windows PowerShell interface to the vSphere API. PowerCLI includes
[cmdlets for administering vSAN components. For information about using vSphere PowerCLI, see the vSphere PowerCLI](https://techdocs.broadcom.com/bin/gethidpage?ux-context-string=vcfa_103&appid=vcf-9-0&language=&format=rendered)
guide.


**How vSAN Differs from Traditional Storage**


Although vSAN shares many characteristics with traditional storage arrays, the overall behavior and function of vSAN is
different.

For example, vSAN can manage and work only with ESXi hosts, and a single vSAN instance provides a single datastore
for the cluster.

vSAN and traditional storage also differ in the following key ways:

- vSAN does not require external networked storage for storing virtual machine files remotely, such as on a Fibre
Channel (FC) or Storage Area Network (SAN).

- Using traditional storage, the storage administrator preallocates storage space on different storage systems. vSAN
automatically turns the local physical storage resources of the ESXi hosts into a single pool of storage. These pools
can be divided and assigned to virtual machines and applications according to their quality-of-service requirements.

- vSAN does not behave like traditional storage volumes based on LUNs or NFS shares. The iSCSI target service uses
LUNs to enable an initiator on a remote ESXi host to transport block-level data to a storage device in the vSAN cluster.

- Some standard storage protocols, such as Fiber Channel Protocol (FCP), do not apply to vSAN.

- vSAN is highly integrated with vSphere. You do not need dedicated plug-ins or a storage console for vSAN, compared
to traditional storage. You can deploy, manage, and monitor vSAN by using the vSphere Client.

- A dedicated storage administrator does not need to manage vSAN. Instead a vSphere administrator can manage a
vSAN environment.

- With vSAN, virtual machine storage policies are automatically assigned when you deploy new virtual machines. The
storage policies can be changed dynamically as needed.


**Building a vSAN Cluster**

You can choose the storage architecture and deployment option when creating a vSAN cluster.

Chose the vSAN storage architecture that best suits your resources and your needs.


**vSAN Express Storage Architecture**

vSAN ESA is designed for high-performance NVMe based TLC flash devices and high performance networks. Each ESXi
host that contributes storage contains a single storage pool of one or more flash devices. Each flash device provides
caching and capacity to the cluster.


VMware by Broadcom 1656


VMware Cloud Foundation 9.0


**vSAN Original Storage Architecture**

vSAN OSA is designed for a wide range of storage devices, including flash solid state drives (SSD) and magnetic disk
drives (HDD). Each ESXi host that contributes storage contains one or more disk groups. Each disk group contains one
flash cache device and one or more capacity devices.


Depending on your requirement, you can deploy vSAN in the following ways.


**vSAN ReadyNode**

The vSAN ReadyNode is a preconfigured solution of the vSAN software provided by Broadcom partners, such as
Cisco, Dell, HPE, Fujitsu, IBM, and Supermicro. This solution includes validated server configuration in a tested,
certified hardware form factor for vSAN deployment that is recommended by the server OEM and VMware. For
information about the vSAN ReadyNode solution for a specific partner, visit the _Broadcom Partner Portal_ [at https://](https://partnerportal.broadcom.com/web/partner-portal)
[partnerportal.broadcom.com/web/partner-portal.](https://partnerportal.broadcom.com/web/partner-portal)

[For more information on vSAN ReadyNode, see the Broadcom knowledge base article 326476.](https://knowledge.broadcom.com/external/article/326476/what-you-can-and-cannot-change-in-a-vsan.html)


**User-Defined vSAN Cluster**

You can build a vSAN cluster by selecting individual software and hardware components, such as drivers, firmware, and
storage I/O controllers that are listed in the _Broadcom Compatibility Guide_ [at https://compatibilityguide.broadcom.com/.](http://www.vmware.com/resources/compatibility/search.php)
You can choose any servers, storage I/O controllers, capacity and flash cache devices, memory, any number of cores
you must have per CPU, that are certified and listed on the Broadcom Compatibility Guide. Review the compatibility
information on the _Broadcom Compatibility Guide_ before choosing software and hardware components, drivers, firmware,
and storage I/O controllers that vSAN supports. When designing a vSAN cluster, use only devices, firmware, and drivers
that are listed on the _Broadcom Compatibility Guide_ . Using software and hardware versions that are not listed in the


VMware by Broadcom 1657


VMware Cloud Foundation 9.0


_Broadcom Compatibility Guide_ might cause cluster failure or unexpected data loss. For information about designing
[a vSAN cluster, see Designing and Sizing a vSAN Cluster. For vSAN ESA requirements, see vSAN ESA ReadyNode](https://partnerweb.vmware.com/comp_guide2/vsanesa_profile.php)
[Hardware Guidance.](https://partnerweb.vmware.com/comp_guide2/vsanesa_profile.php)


**vSAN Deployment Options**


This section covers the supported deployment options for vSAN clusters.


**vSAN HCI Cluster**

vSAN HCI cluster or a single site vSAN cluster consists of a minimum of three ESXi hosts. Typically, all ESXi hosts in a
single site vSAN cluster reside at a single availability zone, and may be connected on the same Layer 2 network. All-flash
configurations including vSAN ESA require network connection of minimum 10 GbE and a network latency of minimum 1
millisecond.

















For more information, see Creating a Single Site vSAN Cluster.


VMware by Broadcom 1658


VMware Cloud Foundation 9.0







**Two-Node vSAN Cluster**

Two-node vSAN clusters are often used for remote office/branch office environments, typically running a small number
of workloads that require high availability. A two-node vSAN cluster consists of two ESXi hosts at the same location,
connected to the same network switch or directly connected. You can configure a two-node vSAN cluster that uses a third
ESXi host as a witness, which can be located remotely from the branch office. Usually the witness resides at the main
site, along with the vCenter. vSAN witness hosts can be shared by multiple vSAN two-node clusters.

[For more information, see Creating a vSAN Stretched Cluster or Two-Node vSAN Cluster and vSAN 2-node Cluster](https://www.vmware.com/docs/vmw-vsan-2-node-cluster-guide)
[Guide.](https://www.vmware.com/docs/vmw-vsan-2-node-cluster-guide)


**vSAN Stretched Cluster**

A vSAN stretched cluster provides resiliency against the loss of an availability zone. The ESXi hosts in a vSAN stretched
cluster can be distributed evenly across two sites. The two sites must have a network latency of no more than five


VMware by Broadcom 1659


VMware Cloud Foundation 9.0


milliseconds (5 ms) round trip (RTT). A vSAN witness ESXi host resides at a third site to provide the witness function. The
witness also acts as tie-breaker in scenarios where a network partition occurs between the two data sites. Only metadata
such as witness components is stored on the witness. The witness and the data sites must have a witness latency of less
than 200 ms RTT. Broadcom recommends a witness latency of 100 ms one way.

For more information, see Creating a vSAN Stretched Cluster or Two-Node vSAN Cluster.


**Compute Cluster**

In a compute cluster, ESXi hosts provide only compute resources and access shared storage from a vSAN storage
cluster. While the compute cluster does not need local storage for vSAN, it must be connected to the vSAN storage cluster
through a 10 GbE or higher network to ensure low latency access to the storage. The compute cluster can contain two or
three hosts based on the workload needs and vCenter requirements.





VMware by Broadcom 1660


VMware Cloud Foundation 9.0


**vSAN Storage Cluster**

A vSAN storage cluster consists of ESXi hosts that contribute only storage resources and do not run virtual machine
workloads. With vSAN ESA architecture, it serves as a storage pool for one or more compute clusters. It requires a
minimum of four hosts to maintain storage availability and fault tolerance. A vSAN storage cluster requires a minimum of
10 GbE network. Broadcom recommends a dedicated 25 GbE or higher network for the vSAN traffic to ensure consistent
[performance between ESXi hosts. For more information, see vSAN ESA ReadyNode Hardware Guidance.](https://partnerweb.vmware.com/comp_guide2/vsanesa_profile.php)





**Integrate vSAN with Other VMware Software**

After you have vSAN up and running, it is integrated with the rest of the VMware software stack.

You can do most of what you can do with traditional storage by using vSphere components and features including
vSphere vMotion, snapshots, clones, vSphere DRS, vSphere HA, VMware Live Site Recovery, and more.


**vSphere HA**

You can enable vSphere HA and vSAN on the same cluster. As with traditional datastores, vSphere HA provides the same
level of protection for virtual machines on vSAN datastores. This level of protection imposes specific restrictions when
vSphere HA and vSAN interact. For specific considerations about integrating vSphere HA and vSAN, see Using vSAN
and vSphere HA.


**Limitations of vSAN**

This topic discusses the limitations of vSAN.

When working with vSAN, consider the following limitations:


VMware by Broadcom 1661


VMware Cloud Foundation 9.0


- vSAN does not support ESXi hosts participating in multiple vSAN clusters. However, a vSAN host can access other
external storage resources that are shared across clusters.

- vSAN does not support vSphere Distributed Power Management (DPM) and Storage I/O Control.

- vSAN does not support SE Sparse disks.

- vSAN does not support Raw Device Mappings (RDM), VMFS, diagnostic partition, and other device access features.

### **Requirements for Enabling vSAN**

Before you deploy a vSAN cluster, verify that your environment meets the requirements for running vSAN.


**Hardware Requirements for vSAN**

Verify that your ESXi hosts and storage devices meet the vSAN hardware requirements.


**Storage Device Requirements**

All capacity devices, drivers, and firmware versions in your vSAN configuration must be certified and listed in the vSAN
section of the _Broadcom Compatability Guide_ [available at: https://compatibilityguide.broadcom.com/.](https://compatibilityguide.broadcom.com/)


**Table 831: vSAN OSA storage device requirements**

|Storage Component|Requirements|
|---|---|
|Cache|•<br>One SAS or SATA solid-state disk (SSD) or PCIe flash device.<br>•<br>Before calculating the**Failures to tolerate**, check the size of the flash<br>caching device in each disk group. For hybrid cluster, it must provide at<br>least 10 percent of the anticipated storage consumed on the capacity<br>devices, not including replicas such as mirrors.<br>•<br>vSphere Flash Read Cache must not use any of the flash devices<br>reserved for vSAN cache.<br>•<br>The cache flash devices must not be formatted with VMFS or another file<br>system.<br>|
|Capacity|•<br>Hybrid group configuration must have at least one SAS or NL-SAS<br>magnetic disk.<br>•<br>All-flash disk group configuration must have at least one SAS, or SATA<br>solid-state disk (SSD), or PCIe flash device.|
|Storage controllers|One SAS or SATA host bus adapter (HBA), or a RAID controller that is in<br>passthrough mode or RAID 0 mode.<br>To avoid issues, consider these points when the same storage controller is<br>backing both vSAN and non-vSAN disks:<br>Do not mix the controller mode for vSAN and non-vSAN disks to avoid<br>handling the disks inconsistently, which can negatively impact vSAN<br>operation. If the vSAN disks are in RAID mode, the non-vSAN disks must<br>also be in RAID mode.<br>When you use non-vSAN disks for VMFS, use the VMFS datastore only for<br>scratch, logging, and core dumps.<br>Do not run virtual machines from a disk or RAID group that shares its<br>controller with vSAN disks or RAID groups.<br>Do not passthrough non-vSAN disks to virtual machine guests as Raw<br>Device Mappings (RDMs).<br>To learn about controller supported features, such as passthrough and<br>RAID, refer to the_Broadcom Compatibility Guide_.|



VMware by Broadcom 1662


VMware Cloud Foundation 9.0


**Table 832: vSAN ESA storage device requirements**

|Storage Component|Requirements|
|---|---|
|Cache and capacity|Each storage pool must have at least one NVMe TLC devices.|



**Host Memory**

The memory requirements for vSAN OSA depend on the number of disk groups and devices that the ESXi hypervisor
[must manage. For more information, see vSAN Sizer tool.](https://vcf.broadcom.com/tools/vsansizer/)

vSAN ESA requires at least 128 GB host memory. The memory needed for your environment depends on the number
[of devices in the host's storage pool. For more information on the guidelines to use with vSAN ESA, see vSAN ESA](https://partnerweb.vmware.com/comp_guide2/vsanesa_profile.php)
[ReadyNode Hardware Guidance.](https://partnerweb.vmware.com/comp_guide2/vsanesa_profile.php)


**Flash Boot Devices**

During installation, the ESXi installer creates a coredump partition on the boot device. The default size of the coredump
partition satisfies most installation requirements.

- If the memory of the ESXi host has 512 GB of memory or less, you can boot the host from a USB, SD, or SATADOM
device. When you boot a vSAN host from a USB device or SD card, the size of the boot device must be at least 32 GB.

- If the memory of the ESXi host has more than 512 GB, consider the following guidelines.

 - You can boot the host from a SATADOM or disk device with a size of at least 16 GB. When you use a SATADOM

device, use a single-level cell (SLC) device.

 - If you are using vSAN, you must resize the coredump partition on ESXi hosts to boot from USB/SD devices.

When you boot an ESXi host from USB device or from SD card, vSAN trace logs are written to RAMDisk. These logs are
automatically offloaded to persistent media during shutdown or system crash (panic). This is the only support method for
handling vSAN traces when booting an ESXi from a USB stick or SD card. If a power failure occurs, vSAN trace logs are
not preserved.

When you boot an ESXi host from a SATADOM device, vSAN trace logs are written directly to the SATADOM device.
Therefore it is important that the SATADOM device meets the specifications outlined in this guide. For more information,
[see ESX Hardware Requirements.](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/esx-installation-and-setup/installing-and-setting-up-esxi/esxi-requirements/esxi-hardware-requirements.html)


**Cluster Requirements for vSAN**

Verify that a host cluster meets the requirements for enabling vSAN.

- All capacity devices, drivers, and firmware versions in your vSAN configuration must be certified and listed in the vSAN
section of the _Broadcom Compatibility Guide_ [at: https://compatibilityguide.broadcom.com/.](https://compatibilityguide.broadcom.com/)

- A standard vSAN cluster must contain a minimum of three ESXi hosts that contribute capacity to the cluster. A two host
vSAN cluster consists of two data hosts and an external witness host. For information about the considerations for a
three-host cluster, see Design Considerations for a vSAN Cluster.

- An ESXi host that resides in a vSAN cluster must not participate in other clusters.


**Software Requirements for vSAN**

Verify that the vSphere components in your environment meet the software version requirements for using vSAN.

To use the full set of vSAN capabilities, the ESXi hosts that participate in vSAN clusters must be version 9.0 or later.
During the vSAN upgrade from previous versions, you can keep the current on-disk format version, but you cannot use
many of the new features. vSAN 9.0 and later software supports all on-disk formats.


VMware by Broadcom 1663


VMware Cloud Foundation 9.0


**Networking Requirements for vSAN**

Verify that the network infrastructure and the networking configuration on the ESXi hosts meet the minimum networking
requirements for vSAN.


**Table 833: Networking Requirements for vSAN**

|Networking Component|Requirement|
|---|---|
|Host Bandwidth|Each host must have minimum bandwidth dedicated to vSAN.<br>•<br>vSAN OSA: Dedicated 1 GbE for hybrid configurations, dedicated or shared<br>10 GbEs for all-flash configurations<br>•<br>vSAN ESA: Dedicated or shared 10 GbEs minimum, recommended 25GbE<br>or higher. SeevSAN Compatibility guide.<br>For information about networking considerations in vSAN, seeDesigning the<br>vSAN Network.|
|Connection between hosts|Each host in the vSAN cluster, regardless of whether it contributes capacity,<br>must have a VMkernel network adapter for vSAN traffic. SeeSet Up a<br>VMkernel Network for vSAN.|
|Host network|All hosts in your vSAN cluster must be connected to a vSAN Layer 2 or Layer 3<br>network.|
|IPv4 and IPv6 support|The vSAN network supports both IPv4 and IPv6.<br>|
|Network latency|•<br>Maximum of 1 ms RTT for single site (non-stretched) vSAN clusters<br>between all hosts in the cluster<br>•<br>Maximum of 5 ms RTT between the two main sites for vSAN stretched<br>clusters<br>•<br>Maximum of 200 ms RTT from a main site to the vSAN witness host<br>•<br>Maximum of 5ms RTT between the vSAN client cluster and vSAN storage<br>cluster|



**License Requirements**

Starting with version 9, product components are licensed automatically after you license the vCenter instance connected
[to the component. You no longer license vSAN manually. For more information, see the VCF Licensing guide.](https://techdocs.broadcom.com/bin/gethidpage?ux-context-string=vcom_839&appid=vcf-9-0&language=&format=rendered)
### **Designing and Sizing a vSAN Cluster**

For best performance and use, plan the capabilities and configuration of your hosts and their storage devices before you
deploy vSAN in a vSphere environment. Carefully consider certain host and networking configurations within the vSAN
cluster.

The Administering VMware vSAN documentation examines the key points about designing and sizing a vSAN cluster. For
[detailed instructions about designing and sizing a vSAN cluster, see VMware vSAN Design Guide.](https://www.vmware.com/docs/vmware-vsan-design-guide)


**Designing and Sizing vSAN Storage**

Plan capacity and cache based on the expected data storage consumption. Consider your requirements for availability
and endurance.


VMware by Broadcom 1664


VMware Cloud Foundation 9.0


**Planning Capacity in vSAN**


You can calculate the capacity of a vSAN datastore to accommodate the virtual machines (VMs) files in the cluster, and to
handle failures and maintenance operations.


**Raw Capacity**

Use this formula to determine the raw capacity of a vSAN datastore. Multiply the total number of disk groups in the cluster
by the size of the capacity devices in those disk groups. Subtract the overhead required by the vSAN on-disk format.


**Failures to Tolerate**

When you plan the capacity of the vSAN datastore, not including the number of virtual machines and the size of their
VMDK files, you must consider the **Failures to tolerate** of the virtual machine storage policies for the cluster.

The **Failures to tolerate** has an important role when you plan and size storage capacity for vSAN. Based on the
availability requirements of a virtual machine, the setting might result in doubled consumption or more, compared with the
consumption of a virtual machine and its individual devices.

For example, if the **Failures to tolerate** is set to **1 failure - RAID-1 (Mirroring)**, virtual machines can use about 50
percent of the raw capacity. If the FTT is set to 2, the usable capacity is about 33 percent. If the FTT is set to 3, the usable
capacity is about 25 percent.

But if the **Failures to tolerate** is set to **1 failure - RAID-5 (Erasure Coding)**, virtual machines can use about 75 percent
of the raw capacity. If the FTT is set to **2 failures - RAID-6 (Erasure Coding)**, the usable capacity is about 67 percent.
For more information about RAID 5/6, see Using RAID 5 or RAID 6 Erasure Coding in vSAN Cluster.

For information about the attributes in a vSAN storage policy, see What are vSAN Policies.


**Capacity Sizing Guidelines**

- Keep some unused space to prevent vSAN from rebalancing the storage load. vSAN rebalances the components
across the cluster whenever the consumption on a single capacity device reaches 80 percent or more. The rebalance
operation might impact the performance of applications. To avoid these issues, keep storage consumption to less than
80 percent. vSAN enables you to manage unused capacity using operations reserve and host rebuild reserve.

- Plan extra capacity to handle any potential failure or replacement of capacity devices, disk groups, and hosts. When
a capacity device is not reachable, vSAN recovers the components from another device in the cluster. When a flash
cache device fails or is removed, vSAN recovers the components from the entire disk group.

- Reserve extra capacity to make sure that vSAN recovers components after a host failure or when a host enters
maintenance mode. For example, provision hosts with enough capacity so that you have sufficient free capacity left for
components to rebuild after a host failure or during maintenance. This extra space is important when you have more
than three hosts, so you have sufficient free capacity to rebuild the failed components. If a host fails, the rebuilding
takes place on the storage available on another host, so that another failure can be tolerated. However, in a threehost cluster, vSAN does not perform the rebuild operation if the **Failures to tolerate** is set to 1 because when one host
fails, only two hosts remain in the cluster. To tolerate a rebuild after a failure, you must have at least three surviving
hosts.

- Provide enough temporary storage space for changes in the vSAN VM storage policy. When you dynamically change a
VM storage policy, vSAN might create a new RAID tree layout of the object. When vSAN instantiates and synchronizes
a new layout, the object may consume extra space temporarily. Keep some temporary storage space in the cluster to
handle such changes.

- If you plan to use advanced features, such as software checksum or deduplication and compression, reserve extra
capacity to handle the operational overhead.

- [You can use vSAN Sizer tool to assist with capacity requirements, operations reserve, and host rebuild reserve, and to](https://vcf.broadcom.com/tools/vsansizer/)
determine how vSAN can meet your performance requirements.


VMware by Broadcom 1665


VMware Cloud Foundation 9.0


**Considerations for Virtual Machine Objects**

When you plan the storage capacity in the vSAN datastore, consider the space required in the datastore for the VM home
namespace objects, snapshots, and swap files.

- VM Home Namespace. You can assign a storage policy specifically to the home namespace object for a virtual
machine. To prevent unnecessary allocation of capacity and cache storage, vSAN applies only the **Failures to tolerate**
and the **Force provisioning** settings from the policy on the VM home namespace. Plan storage space to meet the
requirements for a storage policy assigned to a VM Home Namespace whose **Failures to tolerate** is greater than 0.

- Snapshots. Delta devices inherit the policy of the base VMDK file. Plan extra space according to the expected size and
number of snapshots, and to the settings in the vSAN storage policies. If vSAN ESA is enabled, every snapshot is not
a new object. A base VMDK and its snapshots are contained in one vSAN object.
The space that is required might be different. Its size depends on how often the virtual machine changes data and how
long a snapshot is attached to the virtual machine.

- Swap files. Virtual machine swap files inherit the storage policy of the VM Namespace.


**Design Considerations for Flash Caching Devices in vSAN**


Plan the configuration of flash devices for vSAN cache and all-flash capacity to provide high performance and required
storage space, and to accommodate future growth.


**Flash Devices as vSAN Cache**

Design the configuration of flash cache for vSAN for write endurance, performance, and potential growth based on these
considerations.


**Table 834: Sizing vSAN Cache**









|Storage Configuration|Considerations|
|---|---|
|All-flash and hybrid configurations|•<br>A higher cache-to-capacity ratio eases future capacity growth. Oversizing<br>cache enables you to add more capacity to an existing disk group without<br>the need to increase the size of the cache.<br>•<br>Flash caching devices must have high write endurance.<br>•<br>Replacing a flash caching device is more complicated than replacing a<br>capacity device because such an operation impacts the entire disk group.<br>•<br>If you add more flash devices to increase the size of the cache, you must<br>create more disk groups. The ratio between flash cache devices and disk<br>groups is always 1:1.<br>A configuration of multiple disk groups provides the following advantages:<br>– Reduced risk of failure. If a single caching device fails, fewer capacity<br>devices are affected.<br>– Improved performance if you deploy multiple disk groups that contain<br>smaller flash caching devices.<br>However, when you configure multiple disk groups, the memory<br>consumption of the hosts increases.|
|All-flash configurations|In all-flash configurations, vSAN uses the cache layer for write caching only.<br>The write cache must be able to handle high write activities. This approach<br>extends the life of capacity flash that might be less expensive and might have<br>lower write endurance.|
|Hybrid configurations|The flash caching device must provide at least 10 percent of the anticipated<br>storage that virtual machines are expected to consume, not including replicas<br>such as mirrors. The**Primary level of failures to tolerate** attribute from the<br>VM storage policy does not impact the size of the cache.|


VMware by Broadcom 1666


VMware Cloud Foundation 9.0

|Storage Configuration|Considerations|
|---|---|
||If the read cache reservation is configured in the active VM storage policy, the<br>hosts in the vSAN cluster must have sufficient cache to satisfy the reservation<br>during a post-failure rebuild or maintenance operation.<br>If the available read cache is not sufficient to satisfy the reservation, the rebuild<br>or maintenance operation fails. Use read cache reservation only if you must<br>meet a specific, known performance requirement for a particular workload.<br>The use of snapshots consumes cache resources. If you plan to use several<br>snapshots, consider dedicating more cache than the conventional 10 percent<br>cache-to-consumed-capacity ratio.|



**Design Considerations for Flash Capacity Devices in vSAN**


Plan the configuration of flash capacity devices for vSAN all-flash configurations to provide high performance and required
storage space, and to accommodate future growth.


**Flash Devices as vSAN Capacity**

In all-flash configurations, vSAN does not use cache for read operations and does not apply the read-cache reservation
setting from the VM storage policy. For cache, you can use a small amount of more expensive flash that has high write
endurance. For capacity, you can use flash that is less expensive and has lower write endurance.

Plan a configuration of flash capacity devices by following these guidelines:

- For better performance of vSAN, use more disk groups of smaller flash capacity devices.

- For balanced performance and predictable behavior, use the same type and model of flash capacity devices.


**Design Considerations for Magnetic Disks in vSAN**


Plan the size and number of magnetic disks for capacity in hybrid configurations by following the requirements for storage
space and performance.


**SAS and NL-SAS Magnetic Devices**

Use SAS or NL-SAS magnetic devices by following the requirements for performance, capacity, and cost of the vSAN
storage.

- Compatibility. The model of the magnetic disk must be certified and listed in the vSAN section of the _Broadcom_
_Compatibility Guide_ [availalble at: https://compatibilityguide.broadcom.com/.](https://compatibilityguide.broadcom.com/)

- Performance. SAS and NL-SAS devices have faster performance.

- Capacity. The capacity of SAS or NL-SAS magnetic disks for vSAN is available in the vSAN section of the _Broadcom_
_Compatibility Guide_ . Consider using a larger number of smaller devices instead of a smaller number of larger devices.

- Cost. SAS and NL-SAS devices can be expensive.


**Magnetic Disks as vSAN Capacity**

Plan a magnetic disk configuration by following these guidelines:

- For better performance of vSAN, use many magnetic disks that have smaller capacity.
You must have enough magnetic disks that provide adequate aggregated performance for transferring data between
cache and capacity. Using more small devices provides better performance than using fewer large devices. Using
multiple magnetic disk spindles can speed up the destaging process.
In environments that contain many virtual machines, the number of magnetic disks is also important for read
operations when data is not available in the read cache and vSAN reads it from the magnetic disk. In environments


VMware by Broadcom 1667


VMware Cloud Foundation 9.0


that contain a small number of virtual machines, the disk number impacts read operations if the **Number of disk**
**stripes per object** in the active VM storage policy is greater than one.

- For balanced performance and predictable behavior, use the same type and model of magnetic disks in a vSAN
datastore.

- Dedicate a high enough number of magnetic disks to satisfy the value of the **Failures to tolerate** and the **Number of**
**disk stripes per object** attributes in the defined storage policies. For information about the VM storage policies for
vSAN, see What are vSAN Policies.


**Design Considerations for Storage Controllers in vSAN**


Use storage controllers on the hosts of a vSAN cluster that best satisfy your requirements for performance and availability.

- Use storage controller models, and driver and firmware versions that are listed in the _Broadcom Compatibility Guide_ .
Search for vSAN in the _Broadcom Compatibility Guide_ .

- Use multiple storage controllers, if possible, to improve performance and to isolate a potential controller failure to only
a subset of disk groups.

- Use storage controllers that have the highest queue depths in the _Broadcom Compatibility Guide_ . Using controllers
with high queue depth improves performance. For example, when vSAN is rebuilding components after a failure or
when a host enters maintenance mode.

- Use storage controllers in passthrough mode for best performance of vSAN. Storage controllers in RAID 0 mode
require higher configuration and maintenance efforts compared to storage controllers in passthrough mode.

- Deactivate caching on the controller, or set caching to 100 percent Read.


**Designing and Sizing vSAN Hosts**

Plan the configuration of the hosts in your vSAN cluster for best performance and availability.


**Memory and CPU**

Calculate the memory and the CPU requirements of the hosts in the vSAN cluster based on the following considerations.


**Table 835: Sizing Memory and CPU of vSAN Hosts**

|Compute Resource|Considerations|
|---|---|
|Memory|•<br>Memory per virtual machine<br>•<br>Memory per host, based on the expected number of virtual<br>machines<br>•<br>vSAN OSA must have at least 32 GB memory to support 5<br>disk groups per host and 7 capacity devices per disk group.<br>•<br>vSAN ESA requires at least 128 GB memory.<br>Hosts that have 512 GB memory or less can boot from a USB,<br>SD, or SATADOM device. If the memory of the host is greater than<br>512 GB, boot the host from a SATADOM or disk device.<br>For more information, see the Broadcom knowledge base article<br>2113954.<br>|
|CPU|•<br>Sockets per host<br>•<br>Cores per socket<br>•<br>Number of vCPUs based on the expected number of virtual<br>machines<br>•<br>vCPU-to-core ratio|



VMware by Broadcom 1668


VMware Cloud Foundation 9.0

|Compute Resource|Considerations|
|---|---|
||**Note:**<br>vSAN ESA requires at least 16 CPU cores per host.|



**Host Networking**

Provide more bandwidth for vSAN traffic to improve performance.




- vSAN OSA

 - If you plan to use hosts that have 1 GbE adapters, dedicate adapters for vSAN hybrid. For all-flash configurations,



plan hosts that have dedicated or shared 10 GbE adapters. Use dedicated or shared 25 GbE physical adapters or
higher is recommended.

- If you plan to use 10 GbE adapters, they can be shared with other traffic types for both hybrid and all-flash



configurations.

- vSAN ESA

 - Support the use of dedicated or shared 10 GbE physical adapters. Use dedicated or shared 25 GbE physical



adapters or higher is recommended.

 - Network adapters can be shared with other traffic types.

- If a network adapter is shared with other traffic types, use a vSphere Distributed Switch to isolate vSAN traffic by using
Network I/O Control to manage and prioritize traffic and dedicated VLAN for vSAN traffic

- Create a team of physical adapters to provide redundancy for vSAN traffic.



**Disk Groups vs. Storage Pools**

vSAN OSA uses disk groups to balance performance and reliability. If a flash cache or storage controller stops responding
and a disk group fails, vSAN rebuilds all components from another location in the cluster.

Using multiple disk groups, with each disk group providing a portion of datastore capacity, provides advantages but also
has disadvantages.

- Advantages of multiple disk groups

 - Performance is improved because the datastore has more aggregated cache, and I/O operations are faster.

 - Risk of failure is spread among multiple disk groups.

 - If a disk group fails, vSAN rebuilds fewer components, so performance is improved.

- Disadvantages of multiple disk groups

 - Costs are increased because two or more caching devices are required.

 - More memory is required to handle more disk groups.

 - Multiple storage controllers are required to reduce the risk of a single point of failure.

vSAN ESA uses storage pools, where each device provides both performance and capacity. The number of storage tier
devices has an impact on the performance of vSAN ESA. Broadcom recommends configuring more devices for better
performance. Any single device can fail without impacting the availability of data on any of the other devices in the storage
pool. This design reduces the size of a failure domain.


**Drive Bays**

For easy maintenance, consider hosts whose drive bays and PCIe slots are at the front of the server body.


**Hot Plug and Swap of Devices**

Consider the storage controller passthrough mode support for easy hot plugging or replacement of magnetic disks and
flash capacity devices on a host. If a controller works in RAID 0 mode, you must perform additional steps before the host
can discover the new drive. vSAN ESA requires all NVMe drives and supports hot plugging of these drives.


VMware by Broadcom 1669


VMware Cloud Foundation 9.0


**Design Considerations for a vSAN Cluster**

Design the configuration of hosts and management nodes for best availability and tolerance to consumption growth.


**Sizing the vSAN Cluster for Failures to Tolerate**

You configure the **Failures to tolerate** (FTT) attribute in the VM storage policies to handle host failures. The number
of hosts required for the cluster is calculated as follows: `2 * FTT + 1` . The more failures the cluster is configured to
tolerate, the more capacity hosts are required.

If the cluster hosts are connected across multiple racks, you can organize the hosts into fault domains to improve
resilience against issues such as top-of-rack switch failures and loss of server rack power. See Designing and Sizing
vSAN Fault Domains.


**Limitations of a Two-Host or Three-Host Cluster Configuration**

In a three-host configuration, you can tolerate only one host failure by setting the number of failures to tolerate to 1. vSAN
saves each of the two required replicas of virtual machine data on separate hosts. The witness object is on a third host.
Because of the small number of hosts in the cluster, the following limitations exist:

- When a host fails, vSAN cannot rebuild data on another host to protect against another failure.

- If a host must enter maintenance mode, vSAN cannot evacuate data from the host to maintain policy compliance.
While the host is in maintenance mode, data is exposed to a potential failure or inaccessibility if an additional failure
occurs.
You can use only the **Ensure data accessibility** data evacuation option. **Ensure data accessibility** guarantees that
the object remains available during data migration, although it might be at risk if another failure occurs. vSAN objects
on two-host or three-host clusters are not policy compliant. When the host exits maintenance mode, objects are rebuilt
to ensure policy compliance.
In any situation where two-host or three-host cluster has an inaccessible host or disk group, vSAN objects are at risk of
becoming inaccessible should another failure occur.


**Nested Fault Domains for Two-Node Clusters**

In a two-node configuration, the nested fault domains for two-node clusters allows you to tolerate multiple drive failures
within a host. Each two-node cluster must have at least three disk groups and use a vSAN storage policy that leverages
the nested fault domains capability. The nested fault domains provide protection against disk group failures within a host
by mirroring data within each host in addition to the mirroring between the two hosts.


**Balanced and Unbalanced Cluster Configuration**

vSAN works best on hosts with uniform configurations, including storage configurations.

Using hosts with different configurations has the following disadvantages in a vSAN cluster:

- Reduced predictability of storage performance because vSAN does not store the same number of components on
each host.

- Different maintenance procedures.

- Reduced performance on hosts in the cluster that have smaller or different types of cache devices.


**Deploying vCenter on vSAN**

If the vCenter becomes unavailable, vSAN continues to operate normally and virtual machines continue to run.

If vCenter is deployed on the vSAN datastore, and a problem occurs in the vSAN cluster, you can use a Web browser to
access each ESXi host and monitor vSAN through the vSphere Host Client. vSAN health information is visible in the Host
Client, and also through esxcli commands.


VMware by Broadcom 1670


VMware Cloud Foundation 9.0


**Designing the vSAN Network**

Consider networking features that can provide availability, security, and bandwidth guarantee in a vSAN cluster.

For details about the vSAN network configuration, see Understanding vSAN Networking.


**Networking Failover and Load Balancing**

vSAN uses the teaming and failover policy that is configured on the backing virtual switch for network redundancy only.
vSAN does not use NIC teaming for load balancing.

If you plan to configure a NIC team for availability, consider these failover configurations.

|Teaming Algorithm|Failover Configuration of the Adapters in the Team|
|---|---|
|Route based on originating virtual port|Active/Passive|
|Route based on IP hash|Active/Active with static EtherChannel for the standard switch and<br>LACP port channel for the distributed switch|
|Route based on physical network adapter load|Active/Active|



vSAN supports IP-hash load balancing, but cannot guarantee improvement in performance for all configurations. You can
benefit from IP hash when vSAN is among its many consumers. In this case, IP hash performs load balancing. If vSAN
is the only consumer, you might observe no improvement. This behavior specifically applies to 1 GbE environments. For
example, if you use four 1 GbE physical adapters with IP hash for vSAN, you might not be able to use more than 1 GbEs.
This behavior also applies to all NIC teaming policies that VMware supports.

vSAN does not support multiple VMkernel adapters on the same subnet. You can use different VMkernel adapters on
different subnets, such as another VLAN or separate physical fabric. Providing availability by using several VMkernel
adapters has configuration costs that involve vSphere and the network infrastructure. You can increase network
availability by teaming physical network adapters.


**Using Unicast in vSAN Network**

You can design a simple unicast network for vSAN.

**Note:**

You can use DHCP with reservations, because the assigned IP addresses are bound to the MAC addresses of VMkernel
ports.


**Using RDMA**

vSAN can use Remote Direct Memory Access (RDMA). RDMA typically has lower CPU utilization and less I/O latency. If
your hosts support the RoCE v2 protocol, you can enable RDMA through the vSAN network service in vSphere Client.

Consider the following guidelines when designing vSAN over RDMA:

- Each vSAN host must have a vSAN certified RDMA-capable NIC, as listed in the vSAN section of the _Broadcom_
_Compatibility Guide_ [available at: https://compatibilityguide.broadcom.com/. Use only the same model network adapters](https://compatibilityguide.broadcom.com/)
from the same vendor on each end of the connection. Configure the DCBx mode to IEEE.

- All hosts must support RDMA. If any host loses RDMA support, the entire vSAN cluster switches to TCP.

- The network must be lossless. Configure network switches to use Data Center Bridging with Priority Flow Control.
Configure a lossless traffic class for vSAN traffic marked at priority level 3.

- vSAN with RDMA does not support LACP, IP-hash-based NIC teaming, or route based on physical network adapter
load. vSAN with RDMA does support NIC failover.

- All hosts must be on the same subnet. vSAN with RDMA supports up to 32 hosts.


VMware by Broadcom 1671


VMware Cloud Foundation 9.0


- vSAN with RDMA does not support vSAN stretched clusters and vSAN storage clusters.


**Allocating Bandwidth for vSAN by Using Network I/O Control**

vSAN traffic can share physical network adapters with other system traffic types, such as vSphere vMotion traffic, vSphere
HA traffic, and virtual machine traffic. To guarantee the amount of bandwidth required for vSAN, use vSphere Network I/O
Control in the vSphere Distributed Switch.

In vSphere Network I/O Control, you can configure reservation and shares for the vSAN outgoing traffic.

- Set a reservation so that Network I/O Control guarantees that minimum bandwidth is available on the physical adapter
for vSAN.

- Set shares so that when the physical adapter assigned for vSAN becomes saturated, certain bandwidth is available
to vSAN and to prevent vSAN from consuming the entire capacity of the physical adapter during rebuild and
synchronization operations. For example, the physical adapter might become saturated when another physical adapter
in the team fails and all traffic in the port group is transferred to the other adapters in the team.

For example, on a 10 GbE physical adapter that handles traffic for vSAN, vSphere vMotion, and virtual machines, you can
configure certain bandwidth and shares.


**Table 836: Example Network I/O Control Configuration for a Physical Adapter That Handles vSAN**

|Traffic Type|Shares|
|---|---|
|vSAN|100|
|vSphere vMotion|70|
|Virtual machine|30|



For information about using vSphere Network I/O Control to configure bandwidth allocation for vSAN traffic, see the
[vSphere Networking guide.](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/vsphere-networking.html)


**Marking vSAN Traffic**

Priority tagging is a mechanism to indicate to the connected network devices that vSAN traffic has high Quality of Service
(QoS) demands. You can assign vSAN traffic to a certain class and mark the traffic accordingly with a Class of Service
(CoS) value from 0 (low priority) to 7 (high priority). Use the traffic filtering and marking policy of vSphere Distributed
Switch to configure priority levels.

[For more information, see What is Traffic Filtering and Marking Policy in the](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/vsphere-networking/networking-policies/traffic-filtering-policy.html) _vSphere Networking_ guide.


**Segmenting vSAN Traffic in a VLAN**

Consider isolating vSAN traffic in a VLAN for enhanced security and performance, especially if you share the capacity of
the backing physical adapter among several traffic types.


**Jumbo Frames**

If you plan to use jumbo frames with vSAN to improve CPU performance, verify that jumbo frames are enabled on all
network devices and hosts in the cluster.

By default, the TCP segmentation offload (TSO) and large receive offload (LRO) features are enabled on ESXi. Consider
whether using jumbo frames improves the performance enough to justify the cost of enabling them on all nodes on the
network.


VMware by Broadcom 1672


VMware Cloud Foundation 9.0


**Creating Static Routes for vSAN Networking**


In traditional configurations, where vSphere uses a single default gateway, all routed traffic attempts to reach its
destination through this gateway.

In such cases, you might need to create static routes in your vSAN environment.

vSAN enables you to override the default gateway for the vSAN VMkernel adapter on each host, and configure a gateway
address for the vSAN network. This offers greater flexibility than static routes and simplifies management.

However, certain vSAN deployments might require static routing. For example, deployments where the witness is on
a different network, or the vSAN stretched cluster deployment, where both the data sites and the witness host are on
different networks.

To configure static routing on your ESXi hosts, use the esxcli command:
```
esxcli network ip route ipv4 add -g gateway-to-use –n remote-network
```

_`remote-network`_ is the remote network that your host must access, and _`gateway-to-use`_ is the interface to use when
traffic is sent to the remote network.

For information about network design for vSAN stretched clusters, see vSAN Stretched Clusters Network Design.


**Best Practices for vSAN Networking**


Consider networking best practices for vSAN to improve performance and throughput.

- vSAN OSA: For hybrid configurations, dedicate at least 1 GbE physical network adapter. Place vSAN traffic on a
dedicated or shared 10 GbE physical adapter for best networking performance. For all-flash configurations, use a
dedicated or shared 10 GbE physical network adapter.

- vSAN ESA: Use a dedicated or shared 25 GbE physical network adapter or higher

- Provision one additional physical NIC as a failover NIC.

- If you use a shared network adapter, place the vSAN traffic on a distributed switch and configure Network I/O Control
to guarantee bandwidth to vSAN.


**Designing and Sizing vSAN Fault Domains**

vSAN fault domains can spread redundancy components across the servers in separate computing racks. In this way, you
can protect the environment from a rack-level failure such as loss of power or connectivity.


**Fault Domain Constructs**

vSAN requires at least three fault domains to support **Failures to tolerate** (FTT) of 1. Each fault domain consists of one
or more hosts. Fault domain definitions must acknowledge physical hardware constructs that might represent a potential
zone of failure, for example, an individual computing rack enclosure.

If possible, use at least four fault domains. Three fault domains do not support certain data evacuation modes, and vSAN
is unable to reprotect data after a failure. In this case, you need an additional fault domain with capacity for rebuilding,
which you cannot provide with only three fault domains.

If fault domains are enabled, vSAN applies the active virtual machine storage policy to the fault domains instead of the
individual hosts.

Calculate the number of fault domains in a cluster based on the **FTT** attribute from the storage policies that you plan to
assign to virtual machines.
```
 number of fault domains = 2 * FTT + 1

```

VMware by Broadcom 1673


VMware Cloud Foundation 9.0


If a host is not a member of a fault domain, vSAN interprets it as a stand-alone fault domain.


**Using Fault Domains Against Failures of Several Hosts**

Consider a cluster that contains four server racks, each with two hosts. If the **Failures to tolerate** is set to one and
fault domains are not enabled, vSAN might store both replicas of an object with hosts in the same rack enclosure. In
this way, applications might be exposed to a potential data loss on a rack-level failure. When you configure hosts that
could potentially fail together into separate fault domains, vSAN ensures that each protection component (replicas and
witnesses) is placed in a separate fault domain.

If you add hosts and capacity, you can use the existing fault domain configuration or you can define fault domains.

For balanced storage load and fault tolerance when using fault domains, consider the following guidelines:

- Provide enough fault domains to satisfy the **Failures to tolerate** that are configured in the storage policies.
Define at least three fault domains. Define a minimum of four domains for best protection.

- Assign the same number of hosts to each fault domain.

- Use hosts that have uniform configurations.

- Dedicate one fault domain of free capacity for rebuilding data after a failure, if possible.


**Using Boot Devices and vSAN**

Starting an ESXi installation that is a part of a vSAN cluster from a flash device imposes certain restrictions.

When you boot a vSAN host from a USB/SD device, you must use a high-quality USB or SD flash drive of 4 GbE or larger.

When you boot a vSAN host from a SATADOM device, you must use single-level cell (SLC) device. The size of the boot
device must be at least 16 GbE.

During installation, the ESXi installer creates a coredump partition on the boot device. The default size of the coredump
partition satisfies most installation requirements.

- If the memory of the ESXi host has 512 GB of memory or less, you can boot the host from a USB, SD, or SATADOM
device.

- If the memory of the ESXi host has more than 512 GB, consider the following guidelines.

 - You can boot the host from a SATADOM or disk device with a size of at least 16 GbE. When you use a SATADOM

device, use a single-level cell (SLC) device.

 - If you are using vSAN, you must resize the coredump partition on ESXi hosts to boot from USB/SD devices.

Hosts that boot from a disk have a local VMFS. If you have a disk with VMFS that runs virtual machines, you must
separate the disk for an ESXi boot that is not for vSAN. In this case you need separate controllers.


**Log Information and Boot Devices in vSAN**

When you boot ESXi from a USB or SD device, log information and stack traces are lost on host reboot. They are lost
because the scratch partition is on a RAM drive. Use persistent storage for logs, stack traces, and memory dumps.

Do not store log information on the vSAN datastore. This configuration is not supported because a failure in the vSAN
cluster could impact the accessibility of log information.

Consider the following options for persistent log storage:

- Use a storage device that is not used for vSAN and is formatted with VMFS or NFS.

- Configure the ESXi Dump Collector and vSphere Syslog Collector on the host to send memory dumps and system logs
to vCenter.


VMware by Broadcom 1674


VMware Cloud Foundation 9.0


**Persistent Logging in a vSAN Cluster**

Provide storage for persistence of the logs from the hosts in the vSAN cluster.

If you install ESXi on a USB or SD device and you allocate local storage to vSAN, you might not have enough local
storage or datastore space left for persistent logging.

To avoid potential loss of log information, configure the ESXi Dump Collector and vSphere Syslog Collector to redirect
ESXi memory dumps and system logs to a network server.

### **Preparing a New or Existing Cluster for vSAN**

Before you deploy a vSAN cluster and start using it as virtual machine storage, you must provide the infrastructure that is
required for correct operation of vSAN.


**Preparing Storage**

Provide enough disk space for vSAN and for the virtualized workloads that use the vSAN datastore.

**Verify the Compatibility of Storage Devices**


Consult the _Broadcom Compatability Guide_ to verify that your storage devices, drivers, and firmware are compatible with
vSAN.

By using the vSAN section of the _Broadcom Compatibility Guide_ [available at https://compatibilityguide.broadcom.com/,](https://compatibilityguide.broadcom.com/)
you can select a magnetic disk, flash device, and storage controllers, or check the compatibility of your storage devices for
vSAN.

You can choose from several options for vSAN compatibility.

- Use a vSAN ReadyNode server, a physical server that OEM vendors and VMware validate for vSAN compatibility.

- Assemble a node by selecting individual components from validated device models.

|Broadcom Compatibility Guide Section|Component Type for Verification|
|---|---|
|Systems|Physical server that runs ESXi.<br>|
|vSAN|•<br>Magnetic disk SAS model for hybrid configurations.<br>•<br>Flash device model that is listed in the_Broadcom Compatibility_<br>_Guide_. Certain models of PCIe flash devices can also work<br>with vSAN. Consider also write endurance and performance<br>class.<br>•<br>Storage controller model that supports passthrough.<br>vSAN can work with storage controllers that are configured<br>for RAID 0 mode if each storage device is represented as an<br>individual RAID 0 group.<br>•<br>For vSAN ESA, NVMe TLC drives on Broadcom HCL with<br>capacity 1.6 TB or higher, performance class F higher, and an<br>endurance class of 1 Drive Writes Per Day (DWPD). For more<br>information seevSAN ESA ReadyNode Hardware Guidance.|



**Preparing Storage Devices**


Use flash devices and magnetic disks based on the requirements for vSAN.

Verify that the cluster has the capacity to accommodate anticipated virtual machine consumption and the **Failures to**
**tolerate** in the storage policy for the virtual machines.


VMware by Broadcom 1675


VMware Cloud Foundation 9.0


The storage devices must meet the following requirements so that vSAN can claim them:

- The storage devices are local to the ESXi hosts. vSAN cannot claim remote devices.

- The storage devices do not have any existing partition information.

- On the same host, you cannot have both all-flash and hybrid disk groups.

- For vSAN ESA, NVME drives are only supported.


**Prepare Devices for Storage Pool**

vSAN ESA ready nodes requires a minimum one NVMe drive of 1.6 TB or higher for a storage pool. vSAN storage cluster
ready nodes requires a minimum of two NVMe drives.


**Prepare Devices for Disk Groups**

Each disk group provides one flash caching device and at least one magnetic disk or one flash capacity device. For hybrid
clusters, the capacity of the flash caching device must be at least 10 percent of the anticipated consumed storage on the
capacity device, without the protection copies.

vSAN requires at least one disk group on a host that contributes storage to a cluster that consists of at least three hosts.
Use hosts that have uniform configuration for best performance of vSAN.


**Raw and Usable Capacity**

Provide raw storage capacity that is greater than the capacity for virtual machines to handle certain cases.

- Do not include the size of the flash caching devices as capacity. These devices do not contribute storage and are used
as cache unless you have added flash devices for storage.

- Provide enough space to handle the **Failures to tolerate** (FTT) value in a virtual machine storage policy. A FTT that
is greater than 0 extends the device footprint. If the FTT is set to 1, the footprint is double. If the FTT is set to 2, the
footprint is triple, and so on.

- Verify whether the vSAN datastore has enough space for an operation by examining the space on the individual hosts
rather than on the consolidated vSAN datastore object. For example, when you evacuate a host, all free space in the
datastore might be on the host that you are evacuating. The cluster is not able to accommodate the evacuation to
another host.

- Provide enough space to prevent the datastore from running out of capacity, if workloads that have thinly provisioned
storage start consuming a large amount of storage.

- Verify that the physical storage can accommodate the reprotection and maintenance mode of the hosts in the vSAN
cluster.

- Consider the vSAN overhead to the usable storage space.

 - On-disk format version 3.0 and later adds an extra overhead, typically no more than 1-2 percent capacity per

device. Deduplication and compression with software checksum enabled require extra overhead of approximately
6.2 percent capacity per device.

[For more information about planning the capacity of vSAN datastores, see vSAN Sizer tool.](https://vcf.broadcom.com/tools/vsansizer/home)


**vSAN Policy Impact on Capacity**

The vSAN storage policy for virtual machines affects the capacity devices in several ways.


VMware by Broadcom 1676


VMware Cloud Foundation 9.0


**Table 837: vSAN VM Policy and Raw Capacity**

|Aspects of Policy Influence|Description|
|---|---|
|Policy changes|•<br>The**Failures to tolerate** (FTT) influences the physical storage space<br>that you must supply for virtual machines. The greater the FTT is for<br>higher availability, the more space you must provide.<br>When FTT is set to 1, it imposes two replicas of the VMDK file of a<br>virtual machine. With FTT set to 1, a VMDK file that is 50 GbE requires<br>100 GbE space on different hosts. If the FTT is changed to 2, you must<br>have enough space to support three replicas of the VMDK across the<br>hosts in the cluster, or 150 GbE.<br>•<br>Some policy changes, such as a new number of disk stripes per object,<br>require temporary resources. vSAN recreates the objects affected by<br>the change. For a certain time, the physical storage must accommodate<br>the old and new objects.|
|Available space for reprotecting or maintenance mode|When you place a host in maintenance mode or you clone a virtual<br>machine, the datastore might not be able to evacuate the virtual machine<br>objects, although the vSAN datastore indicates that enough space is<br>available. This lack of space can occur if the free space is on the host that<br>is being placed in maintenance mode.|



**Preparing Storage Controllers**


Configure the storage controller on each host according to the requirements of vSAN.

Verify that the storage controllers on the vSAN hosts satisfy certain requirements for mode, driver, and firmware version,
queue depth, caching, and advanced features.


**Table 838: Examining Storage Controller Configuration for vSAN OSA**

|Storage Controller Feature|Storage Controller Requirement|
|---|---|
|Required mode|•<br>Review the vSAN requirements in the_Broadcom Compatibility Guide_ for the<br>required mode, passthrough or RAID 0, of the controller.<br>•<br>If both passthrough and RAID 0 modes are supported, configure passthrough<br>mode instead of RAID0. RAID 0 introduces complexity for disk replacement.<br>|
|RAID mode|•<br>In the case of RAID 0, create one RAID volume per physical disk device.<br>•<br>Do not enable a RAID mode other than the mode listed in the_Broadcom_<br>_Compatibility Guide_.<br>•<br>Do not enable controller spanning.<br>|
|Driver and firmware version|•<br>Use the latest driver and firmware version for the controller according to<br>_Broadcom Compatibility Guide_.<br>•<br>If you use the in-box controller driver, verify that the driver is certified for vSAN.<br>OEM ESXi releases might contain drivers that are not certified and listed in the<br>_Broadcom Compatibility Guide_.|
|Queue depth|Verify that the queue depth of the controller is 256 or higher. Higher queue depth<br>provides improved performance.|
|Cache|Deactivate the storage controller cache, or set it to 100 percent read if disabling<br>cache is not possible.|
|Advanced features|Deactivate advanced features, for example, HP SSD Smart Path.|



VMware by Broadcom 1677


VMware Cloud Foundation 9.0


**Mark Flash Devices as Capacity Using ESXCLI**


You can manually mark the flash devices on each host as capacity devices using esxcli.

Verify that you are using vSAN 9.0 or later.

1. To learn the name of the flash device that you want to mark as capacity, run the following command on each host.

a) In the ESXi Shell, run the `esxcli storage core device list` command.
b) Locate the device name at the top of the command output and write the name down.
The command takes the following options:


**Table 839: Command Options**

|Options|Description|
|---|---|
|`-d|--disk=str`|The name of the device that you want to tag as a capacity device. For example,`mpx.vmhba1`<br>`:C0:T4:L0`|
|`-t|--tag=str`|Specify the tag that you want to add or remove. For example, the`capacityFlash` tag is<br>used for marking a flash device for capacity.|



The command lists all device information identified by ESXi.

2. In the output, verify that the `Is SSD` attribute for the device is `true` .

3. To tag a flash device as capacity, run the `esxcli vsan storage tag add -d <device name> -t capacityFlash`

command.
For example, the `esxcli vsan storage tag add -t capacityFlash -d mpx.vmhba1:C0:T4:L0` command, where
`mpx.vmhba1:C0:T4:L0` is the device name.

4. Verify whether the flash device is marked as capacity.

a) In the output, identify whether the `IsCapacityFlash` attribute for the device is set to `1` .

**Command Output**

You can run the `vdq -q -d <device name>` command to verify the `IsCapacityFlash` attribute. For example,
running the `vdq -q -d mpx.vmhba1:C0:T4:L0` command, returns the following output.
```
   \{
   "Name"   : "mpx.vmhba1:C0:T4:L0",
   "VSANUUID" : "",
   "State"  : "Eligible for use by VSAN",
   "ChecksumSupport": "0",
   "Reason"  : "None",
   "IsSSD"  : "1",
   "IsCapacityFlash": "1",
   "IsPDL"  : "0",
   \},
```

**Untag Flash Devices Used as Capacity Using ESXCLI**


You can untag flash devices that are used as capacity devices, so that they are available for caching.


VMware by Broadcom 1678


VMware Cloud Foundation 9.0


1. To untag a flash device marked as capacity, run the `esxcli vsan storage tag remove -d <device name> -`

`t capacityFlash` command. For example, the `esxcli vsan storage tag remove -t capacityFlash -d`
`mpx.vmhba1:C0:T4:L0` command, where `mpx.vmhba1:C0:T4:L0` is the device name.

2. Verify whether the flash device is untagged.

a) In the output, identify whether the `IsCapacityFlash` attribute for the device is set to `0` .

**Command Output**

You can run the `vdq -q -d <device name>` command to verify the `IsCapacityFlash` attribute. For example,
running the `vdq -q -d mpx.vmhba1:C0:T4:L0` command, returns the following output.

```
   [
   \{
   "Name"   : "mpx.vmhba1:C0:T4:L0",
   "VSANUUID" : "",
   "State"  : "Eligible for use by VSAN",
   "ChecksumSupport": "0",
   "Reason"  : "None",
   "IsSSD"  : "1",
   "IsCapacityFlash": "0",
   "IsPDL"  : "0",
   \},

```

**Providing Memory for vSAN**

Provision hosts with memory to support to the maximum number of devices and disks that you intend to use for vSAN.

For vSAN OSA to satisfy the combination of devices and disk groups, you must provision hosts with 32 GB of memory
[for system operations. For information about the maximum device configuration, refer to the vSphere Configuration](https://configmax.broadcom.com)
[Maximums guide and see the Broadcom knowledge base article 2113954. vSAN ESA requires a minimum of 128 GB of](https://configmax.broadcom.com)
[memory. To calculate vSAN memory overhead, see vSAN Sizer tool.](https://vcf.broadcom.com/tools/vsansizer)


**Preparing Your Hosts for vSAN**

As a part of the preparation for enabling vSAN, review the requirements and recommendations about the configuration of
hosts for the cluster.

- Verify that the storage devices on the hosts, and the driver and firmware versions for them, are listed in the vSAN
section of the _Broadcom Compatibility Guide_ [available at: https://compatibilityguide.broadcom.com/.](https://compatibilityguide.broadcom.com/)

- Make sure that a minimum of three hosts contribute storage to the vSAN datastore.

- For maintenance and remediation operations on failure, add at least four hosts to the cluster.

- Designate hosts that have uniform configuration for best storage balance in the cluster.

- Do not add hosts that have only compute resources to the cluster to avoid unbalanced distribution of storage
components on the hosts that contribute storage. Virtual machines that require much storage space and run on
compute-only hosts might store a great number of components on individual capacity hosts. As a result, the storage
performance in the cluster might be lower.

- Do not configure aggressive CPU power management policies on the hosts for saving power. Certain applications that
are sensitive to CPU speed latency might have low performance.

- If your cluster contains blade servers, consider extending the capacity of the datastore with an external storage
enclosure that is connected to the blade servers. Make sure the storage enclosure is listed in the vSAN section of the
_Broadcom Compatibility Guide_ .


VMware by Broadcom 1679


VMware Cloud Foundation 9.0


- Consider the configuration of the workloads that you place on vSAN:

 - For high levels of predictable performance, use vSAN ESA based clusters.

 - For balance between performance and older hardware, consider using vSAN OSA


**vSAN and vCenter Compatibility**

Synchronize the versions of vCenter and ESXi to avoid potential faults caused by mismatched software.

For best integration between vSAN components on vCenter and ESXi, deploy the latest version of the two vSphere
components. See the following:

- [vCenter Deployment and Setup guide](https://techdocs.broadcom.com/bin/gethidpage?ux-context-string=vsphclient_047&appid=vsphere-9-0&language=&format=rendered)

- [VMware ESX Upgrade guide](https://techdocs.broadcom.com/bin/gethidpage?ux-context-string=vsphclient_008&appid=vsphere-9-0&language=&format=rendered)

- [vCenter Upgrade guide](https://techdocs.broadcom.com/bin/gethidpage?ux-context-string=vsphclient_006&appid=vsphere-9-0&language=&format=rendered)


**Configuring the vSAN Network**

Before you enable vSAN on a cluster of ESXi hosts, you must provide the necessary network infrastructure to carry vSAN
communication.

vSAN provides a distributed storage solution, which implies exchanging data across the ESXi hosts that participate in the
cluster. Preparing the network for installing vSAN includes certain configuration aspects.

For information about network design guidelines, see Designing the vSAN Network.


**Placing Hosts in the Same Subnet**

Hosts must be connected in the same subnet for best networking performance. vSAN can also connect hosts in the same
Layer 3 network if necessary.


**Dedicating Network Bandwidth on a Physical Adapter**

Allocate at least 1 GbE bandwidth for vSAN. You might use one of the following configuration options:

- vSAN OSA: Dedicate 1 GbE physical adapters for a hybrid host configuration, or use dedicated or shared 10 GbE
physical adapters if possible. Use dedicated or shared 10 GbE physical adapters for all-flash configurations.

- vSAN ESA: Support the use of dedicated or shared 10 GbE physical adapters. Use dedicated or shared 25 GbE
physical adapters or higher is recommended.

- Direct vSAN traffic on a physical adapter that handles other system traffic and use vSphere Network I/O Control on a
distributed switch to configure shares for vSAN.


**Configuring a Port Group on a Virtual Switch**

Configure a port group on a virtual switch for vSAN.

- Assign the physical adapter for vSAN to the port group as an active uplink.
When you need a NIC team for network availability, select a teaming algorithm based on the connection of the physical
adapters to the switch.

- If designed, assign vSAN traffic to a VLAN by enabling tagging in the virtual switch.


**Examining the Firewall on a Host for vSAN**

vSAN sends messages on certain ports on each host in the cluster. Verify that the host firewalls allow traffic on these
ports.


VMware by Broadcom 1680


VMware Cloud Foundation 9.0


When you enable vSAN on a cluster, all required ports are added to ESXi firewall rules and configured automatically.
There is no need for an administrator to open any firewall ports or enable any firewall services manually.

You can view open ports for incoming and outgoing connections. Select the ESXi host, and click **Configure** - **Security**
**Profile** .

### **Creating a Single Site vSAN Cluster**

You can enable vSAN when you create a vSphere cluster, or you can or enable vSAN on an existing clusters.


**Characteristics of a vSAN Cluster**

Before working on a vSAN environment, be aware of the characteristics of a vSAN cluster.

A vSAN cluster includes the following characteristics:

- You can have multiple vSAN clusters for each vCenter instance. You can use a single vCenter to manage more than
one vSAN cluster.

- vSAN consumes all devices, including flash cache and capacity devices, and does not share devices with other
features.

- vSAN clusters can include ESXi hosts with or without capacity devices. The minimum requirement is three ESXi hosts
with capacity devices. For best results, create a vSAN cluster with uniformly configured ESXi hosts.

- If a ESX host contributes capacity, it must have at least one flash cache device and one capacity device. vSAN ESA
requires a minimum of one capacity device.

- In hybrid clusters, the magnetic disks are used for capacity and flash devices for read and write cache. vSAN allocates
70 percent of all available cache for read cache and 30 percent of available cache for the write buffer. In a hybrid
configuration, the flash devices serve as a read cache and a write buffer.

- In all-flash clusters, one designated flash device is used as a write cache, additional flash devices are used for
capacity. In all-flash clusters, all read requests come directly from the flash pool capacity.

- For vSAN ESA clusters, capacity drives contribute to cache and capacity.

- Only local or direct-attached capacity devices can participate in a vSAN cluster. vSAN cannot consume other external
storage, such as SAN or NAS, attached to cluster.

To learn about the characteristics of a vSAN cluster configured through Quickstart, see Using Quickstart to Configure and
Expand a vSAN Cluster .

For best practices about designing and sizing a vSAN cluster, see Designing and Sizing a vSAN Cluster.


**Before Creating a vSAN Cluster**

This topic provides a checklist of software and hardware requirements for creating a vSAN cluster. You can also use the
checklist to verify that the cluster meets the guidelines and basic requirements.


**Requirements for vSAN Cluster**

Before you get started, verify specific models of hardware devices, and specific versions of drivers and firmware in the
_Broadcom Compatibility Guide_ [available at https://compatibilityguide.broadcom.com/. The following table lists the key](http://www.vmware.com/resources/compatibility/search.php)
software and hardware requirements supported by vSAN.

**CAUTION:** Using uncertified software and hardware components, drivers, controllers, and firmware might cause
unexpected data loss and performance issues.


VMware by Broadcom 1681


VMware Cloud Foundation 9.0


**Table 840: vSAN Cluster Requirements**

|Requirements|Description|
|---|---|
|ESXi hosts|•<br>Verify that you are using the latest version of ESXi on your hosts.<br>•<br>Verify that there are at least three ESXi hosts with supported storage configurations<br>available to be assigned to the vSAN cluster. For best results, configure the vSAN<br>cluster with four or more ESXi hosts.<br>|
|Memory|•<br>Verify that each ESXi host has a minimum of 32 GB of memory.<br>•<br>Verify that vSAN ESA has a minimum of 128 GB of memory.<br>•<br>For larger configurations, better performance, and to calculate required memory, see<br>vSAN Sizer tool.<br>|
|Storage I/O controllers, drivers, firmware|•<br>Verify that the storage I/O controllers, drivers, and firmware versions are certified and<br>listed in the_Broadcom Compatibility Guide_ available athttps://compatibilityguide.broa<br>dcom.com/.<br>•<br>Verify that the controller is configured for passthrough or RAID 0 mode.<br>•<br>Verify that the controller cache and advanced features are deactivated. If you cannot<br>deactivate the cache, you must set the read cache to 100 percent.<br>•<br>Verify that you are using controllers with higher queue depths. Using controllers with<br>queue depths less than 256 can significantly impact the performance of your virtual<br>machines during maintenance and failure.<br>**Note:**<br>vSAN ESA supports NVMe drives and does not support storage controllers.<br>|
|Cache and capacity|•<br>For vSAN OSA, verify that vSAN hosts contributing storage to the cluster have at<br>least one cache and one capacity device. vSAN requires exclusive access to the<br>local cache and capacity devices of the ESXi hosts in the vSAN cluster. They cannot<br>share these devices with other uses, such as Virtual Flash File System (VFFS), VMFS<br>partitions, or an ESXi boot partition.<br>•<br>For vSAN ESA, verify that ESXi hosts contributing storage have compatible flash<br>storage devices.<br>•<br>For best results, create a vSAN cluster with uniformly configured ESXi hosts.<br>|
|Network connectivity|•<br>Verify that each ESXi host is configured with at least one network adapter.<br>•<br>For hybrid configurations, verify that vSAN hosts have a minimum dedicated<br>bandwidth of 1 GbE.<br>•<br>For all-flash configurations, verify that vSAN hosts have a minimum bandwidth of 10<br>GbE.<br>For best practices and considerations about designing the vSAN network, seeDesigning<br>the vSAN Network andNetworking Requirements for vSAN.|
|vSAN and vCenter compatibility|Verify that you are using the latest version of the vCenter.|



For detailed information about vSAN cluster requirements, see Requirements for Enabling vSAN.

[For in-depth information about designing and sizing the vSAN cluster, see the VMware vSAN Design and Sizing Guide.](https://www.vmware.com/docs/vmware-vsan-design-guide)


**Using Quickstart to Configure and Expand a vSAN Cluster**

You can use the Quickstart workflow to quickly create, configure, and expand a vSAN cluster.

Quickstart consolidates the workflow to enable you to quickly configure a new vSAN cluster that uses recommended
default settings for common functions such as networking, storage, and services. Quickstart groups common tasks and


VMware by Broadcom 1682


VMware Cloud Foundation 9.0


uses configuration wizards that guide you through the process. Once you enter the required information on each wizard,
Quickstart configures the cluster based on your input.

Quickstart uses the vSAN health service to validate the configuration and help you correct configuration issues. Each
Quickstart card displays a configuration checklist. You can click a green message, yellow warning, or red failure to display
details.

Hosts added to a Quickstart cluster are automatically configured to match the cluster settings. The ESX software and
patch levels of new hosts must match those in the cluster. Hosts cannot have any networking or vSAN configuration
when added to a cluster using the Quickstart workflow. For more information about adding hosts, see Expanding a vSAN
Cluster.

**Note:** If you modify any network settings outside of QuickStart, this hampers your ability to add and configure more hosts
to the cluster using the QuickStart workflow.


**Characteristics of a Quickstart Cluster**

A vSAN cluster configured using Quickstart has the following characteristics.

- Hosts must have ESX 9.0 or later.

- Host all have similar configuration, including network settings. Quickstart modifies network settings on each host to
match the cluster requirements.

- Cluster configuration is based on recommended default settings for networking and services.

- Licenses are allocated to vCenter and gets automatically assigned to the vSAN clusters.


**Managing and Expanding a Quickstart Cluster**

Once you complete the Quickstart workflow, you can manage the cluster through vCenter, using the vSphere Client or
command-line interface.

You can use the Quickstart workflow to add hosts to the cluster and claim additional disks. But once the cluster is
configured through Quickstart, you cannot use Quickstart to modify the cluster configuration.

The Quickstart workflow is available only through the HTML5-based vSphere Client.


**Skipping Quickstart**

You can use the **Skip Quickstart** button to exit the Quickstart workflow, and continue configuring the cluster and its hosts
manually. You can add new hosts individually, and manually configure those hosts. Once skipped, you cannot restore the
Quickstart workflow for the cluster.

The Quickstart workflow is designed for new clusters. When you upgrade an existing vSAN cluster, the Quickstart
workflow appears. Skip the Quickstart workflow and continue to manage the cluster through vCenter.


**Use Quickstart to Configure a vSAN Cluster**


You can use the Quickstart workflow to quickly configure a vSAN cluster.

- Verify that hosts are running ESXi 9.0 or later.

- Verify that ESX hosts in the cluster do not have any existing vSAN or networking configuration.

**Note:** If you perform network configuration through Quickstart, then modify those parameters from outside of Quickstart,
you cannot use Quickstart to add or configure additional hosts.


VMware by Broadcom 1683


VMware Cloud Foundation 9.0


1. Navigate to the new cluster in the vSphere Client.

2. Click the Configure tab, and select **Configuration > Quickstart** .

3. (optional) On the Cluster basics card, click **Edit** to open the Cluster basics wizard.

a) (Optional) Enter a cluster name.
b) Select basic services, such as DRS, vSphere HA, and vSAN.

Check **Enable vSAN ESA** to use vSAN ESA. vSAN ESA is optimized for high-performance flash storage devices
that provide greater performance and efficiency.
c) Select any option to **Choose how to set up the cluster's image** .
d) Select **Manage configuration at a cluster level** check box to ensure that all the hosts in the cluster have the

same settings.
e) Click **Next** .
f) Select an image from the Image Library of Lifecycle Manager.
g) Click **Next** and review the cluster details.
h) Click **Finish** .

4. On the Add hosts card, click **Add** to open the Add hosts wizard.

a) On the Add hosts page, enter information for new hosts, or click Existing hosts and select from hosts listed in the

inventory.
b) On the Host summary page, verify the host settings.
c) On the Ready to complete page, click **Finish** .

**Note:**

If you are running vCenter on a host, the host cannot be placed into maintenance mode as you add it to a cluster using
the Quickstart workflow. All other virtual machines on the host must be powered off.

5. On the Cluster configuration card, click **Configure** to open the Cluster configuration wizard.

a) (vSAN ESA clusters) On the Cluster Type page, enter the HCI cluster type:

    - **vSAN HCI** provides compute resources and storage resources. The datastore can be shared across data
centers and vCenter instances.

    - **vSAN storage cluster** provides storage resources, but not compute resources. The datastore can be mounted
by remote vSAN clusters across data centers and vCenter instances.
b) On the Configure the distributed switches page, enter networking settings, including distributed switches, port

groups, and physical adapters.

    - In the **Distributed switches** section, enter the number of distributed switches to configure from the drop-down
menu. Enter a name for each distributed switch. Click **Use Existing** to select an existing distributed switch.
If the host has a standard virtual switch with the same name as the selected distributed switch, the standard
switch is migrated to the corresponding distributed switch.
Network resource control is enabled and set to version 3. Distributed switches with network resource control
version 2 cannot be used.

    - In the **Port Groups** section, select a distributed switch to use for vMotion and a distributed switch to use for the
vSAN network.

    - In the **Physical adapters** section, select a distributed switch for each physical network adapter. You must
assign each distributed switch to at least one physical adapter.
If the physical adapters chosen are attached to a standard virtual switch with the same name across hosts, the
standard switch is migrated to the distributed switch. If the physical adapters chosen are unused, there is no
migration from standard switch to distributed switch.


VMware by Broadcom 1684


VMware Cloud Foundation 9.0


Network resource control is enabled and set to version 3. Distributed switches with network resource control
version 2 cannot be used.
c) On the vMotion traffic page, enter IP address information for vMotion traffic.
d) On the Storage traffic page, enter IP address information for storage traffic.
e) On the Advanced options page, enter information for cluster settings, including DRS, HA, vSAN, host options, and

EVC.
f) On the Claim disks page, select storage devices on each host. For clusters with vSAN OSA, select one cache
device and one or more capacity devices. For clusters with vSAN ESA, select flash devices for the host's storage
pool.

**Note:**

Only the vSAN Data Persistence platform can consume vSAN Direct storage. The vSAN Data Persistence platform
provides a framework for software technology partners to integrate with VMware infrastructure. Each partner must
develop their own plug-in for VMware customers to receive the benefits of the vSAN Data Persistence platform.
The platform is not operational until the partner solution running on top is operational. For more information, see
the _vSphere Supervisor Concepts_ guide.
g) (Optional) On the Create fault domains page, define fault domains for hosts that can fail together.

For more information about fault domains, see Managing Fault Domains in vSAN Clusters.
h) (Optional) On the Proxy setting page, configure the proxy server if your system uses one.
i) On the Review page, verify the cluster settings, and click **Finish** .

You can manage the cluster through your vCenter.

You can add hosts to the cluster through Quickstart. For more information. see Expanding a vSAN Cluster.


**Manually Enabling vSAN**

To create a vSAN cluster, you create a vSphere host cluster and enable vSAN on the cluster.

A vSAN cluster can include hosts with capacity and hosts without capacity. Follow these guidelines when you create a
vSAN cluster.

- A vSAN cluster must include a minimum of three ESXi hosts. For a vSAN cluster to tolerate host and device failures,
at least three hosts that join the vSAN cluster must contribute capacity to the cluster. For best results, consider adding
four or more hosts contributing capacity to the cluster.

- Only ESXi hosts can join the vSAN cluster.

- Before you move a host from a vSAN cluster to another cluster, make sure that the destination cluster is vSAN
enabled.

- To be able to access the vSAN datastore, an ESXi host must be a member of the vSAN cluster.

After you enable vSAN, the vSAN storage provider is automatically registered with vCenter and the vSAN datastore is
[created. For information about storage providers, see the vSphere Storage guide.](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/vsphere-storage.html)


**Set Up a VMkernel Network for vSAN**


To enable the exchange of data in the vSAN cluster, you must provide a VMkernel network adapter for vSAN traffic on
each ESXi host.


VMware by Broadcom 1685


VMware Cloud Foundation 9.0


1. Right-click the host, and select **Add Networking** .

2. On the **Select connection type** page, select **VMkernel Network Adapter** and click **Next** .

3. On the **Select target device** page, configure the target switching device.

4. On the **Port properties** page, select **vSAN** service. The configuration of vSAN or vSAN witness network interface with

vSAN Storage cluster client network interface is not supported.

5. Complete the VMkernel adapter configuration.

6. On the **Ready to complete** page, verify that vSAN is Enabled in the status for the VMkernel adapter, and click **Finish** .


vSAN network is enabled for the host.

You can enable vSAN on the host cluster.

**Create a vSAN Cluster**


You can create a cluster, and then configure the cluster for vSAN.

1. Right-click a data center and select **New Cluster** .

2. Type a name for the cluster in the **Name** text box.

3. Turn on DRS, vSphere HA, and vSAN for the cluster.

Check **Enable vSAN ESA** to use vSAN ESA. vSAN ESA is optimized for high-performance flash storage devices that
provide greater performance and efficiency.

4. Select any option to **Choose how to set up the cluster's image** . For more information on setting up cluster image,

[see Create a Cluster That Uses an Image by Composing a New Image in the](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/managing-host-and-cluster-lifecycle/cluster-operations-and-vsphere-lifecycle-manager.html#GUID-1CC78B7E-2AD4-4442-ADFD-37E841B969AE-en) _Managing Host and Cluster Lifecycle_
guide.

5. (Optional) Select **Manage configuration at a cluster level** check box to ensure that all the ESXi hosts in the cluster

have the same settings.

6. Click **Next** .

7. Select an image from the Image Library of Lifecycle Manager.

8. Click **Next** and review the cluster details.

9. Click **Finish** .

The cluster appears in the inventory.

10. Add hosts to the vSAN cluster.

vSAN clusters can include hosts with or without capacity devices. For best results, add hosts with capacity.

Configure services for the vSAN cluster. See Configure a vSAN Cluster Using the vSphere Client.

**Configure a Cluster for vSAN Using the vSphere Client**


You can use the vSphere Client to configure vSAN on an existing cluster.

- Verify that your environment meets all requirements. See Requirements for Enabling vSAN.

- Create a vSphere cluster and add ESXi hosts to the vSphere cluster before enabling and configuring vSAN. Configure
the port properties on each ESXi host to add the vSAN service.

**Note:**

You can use Quickstart to quickly create and configure a vSAN cluster. For more information, see Use Quickstart to
Configure a vSAN Cluster.


VMware by Broadcom 1686


VMware Cloud Foundation 9.0


1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, select **Services** .

a) Select an HCI configuration type.

    - **vSAN HCI** provides compute resources and storage resources. The datastore can be shared across clusters in
the same data center, and across clusters managed by remote vCenter instances.

    - **Compute Cluster** is a vSphere cluster that can mount a remote datastore from a vSAN storage cluster. These
clusters are ESXi hosts in a vSphere cluster that only complies with the _Broadcom Compatibility Guide_ at
[https://compatibilityguide.broadcom.com/.](https://compatibilityguide.broadcom.com/)

    - **vSAN Storage Cluster** (deployment model based on vSAN ESA) provides storage resources, but not compute
resources. The datastore can be mounted by client vSphere clusters and vSAN clusters in the same data center
and from remote vCenter instances.
b) Select a deployment option ( **Single site vSAN cluster**, **Two node vSAN cluster**, or **vSAN stretched cluster** ).
c) Click **Configure** to open the Configure vSAN wizard.

4. Select vSAN ESA if your cluster is compatible, and click **Next** .

  - Select **vSAN managed disk claim** to claim all compatible disks on the existing host cluster. Ensure that the vSAN
disks are compatible with the vSAN Hardware Compatibility List.

  - Select **Auto-Policy management** to optimize capacity utilization based on the cluster size and type.

5. Configure the vSAN services to use, and click **Next** .

  - Configure data management features, including deduplication and compression, data-at-rest encryption, data-intransit encryption.

  - Select RDMA (remote direct memory access) if your network supports it.

  - If you configure a vSAN storage cluster, you get the option to **Use Storage cluster client network** . You can select
this option to separate the external VM traffic from the internal storage traffic by utilizing the dedicated VMkernel
ports for different traffic types. After enabling this option, you cannot modify the network configuration.

  - Create and assign a default datastore policy for vSAN ESA. This auto-policy management allows best capacity
utilization after the cluster configuration is complete.

6. Claim disks for the vSAN cluster, and click **Next** .

For vSAN OSA, each ESXi host that contribute storage requires at least one flash device for cache, and one or more
devices for capacity. For vSAN ESA, each ESXi host that contributes storage requires one or more flash devices.

7. (Optional) Create fault domains to group ESXi hosts that can fail together.

8. Review the configuration, and click **Finish** .


Enabling vSAN creates a vSAN datastore and registers the vSAN storage provider. vSAN storage providers are built-in
software components that communicate the storage capabilities of the datastore to vCenter.

- Verify that the vSAN datastore has been created. See View vSAN Datastore.

- Verify the health of the new vSAN cluster created. See Check vSAN Skyline Health.

- Verify that the vSAN storage provider is registered. See View vSAN Storage Providers.


VMware by Broadcom 1687


VMware Cloud Foundation 9.0


**Edit vSAN Settings**


You can edit the settings of your vSAN cluster to configure data management features and enable services provided by
the cluster.

Edit the settings of an existing vSAN cluster if you want to enable deduplication and compression, compression only, or
to enable encryption. If you enable deduplication and compression, or if you enable encryption, the on-disk format of the
cluster is automatically upgraded to the latest version.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, select **Services** .

4. Click the **Edit** or **Enable** button for the service you want to configure.




- Configure Storage. Using the vSAN **ESA Options** dialog, you can enable vSAN managed disk claim and AutoPolicy management.

- Configure Performance Service. For more information, see Monitoring vSAN Performance.

- Enable file service. For more information, see vSAN File Service.

- Configure vSAN Network options. Enable RDMA if your network supports it.

- Configure vSAN Data Protection. Before you can use vSAN Data Protection, you must deploy the VMware Live
Recovery appliance.

- Configure iSCSI target service. For more information, see Using the vSAN iSCSI Target Service.

- Configure Data Services, including space efficiency, data-at-rest encryption, and data-in-transit encryption. You can
select **Allow reduced redundancy** to enable features like deduplication and compression and encryption while
temporarily reducing the level of data protection for VMs. For more information, see Enable Deduplication and
Compression on an Existing vSAN Cluster.

- Configure capacity reservations and alerts. For more information, see About Reserved Capacity in vSAN Cluster.

- Configure advanced options:

 - Object repair timer. For more information, see Monitor the Resynchronization Tasks in vSAN Cluster.

 - Site read locality. In the stretched cluster environments, the reads to vSAN objects occur to the local VM object



location. When you enable the site read locality, the reads occur on the local and the remote sites. You can
disable the site read locality for two-node vSAN clusters.

- Thin swap. When you enable thin swap, the VM swap objects does not reserve 100 percentage of the swap



capacity.

- Guest Trim/Unmap. This option is enabled by default for vSAN ESA cluster. For more information, see



Reclaiming Storage Space in vSAN with SCSI Unmap.

 - Automatic rebalance. For more information, see Configure Automatic Rebalance in vSAN Cluster.

- Configure vSAN historical health service. For more information, see About the vSAN Skyline Health.



5. Modify the settings to match your requirements.

6. Click **Apply** to confirm your selections.

**Enable vSAN on an Existing Cluster**


You can enable vSAN on an existing cluster, and configure features and services.

- Verify that your environment meets all requirements. See Requirements for Enabling vSAN.

- Ensure that the vSAN network on the existing vSAN cluster has a VMkernel NIC, configured with a static or DHCP IP
address and the VMkernel port tagged with the vSAN traffic.


VMware by Broadcom 1688


VMware Cloud Foundation 9.0


1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, select **Services** .

a) Select a configuration type ( **vSAN HCI**, **Two node vSAN cluster**, **vSAN Stretched cluster, Compute Cluster, or**

**vSAN Storage Cluster** ).
b) Select **I need local vSAN Datastore** if you plan to add disk groups or storage pools to the cluster ESXi hosts.
c) Click **Configure** to open the **Configure vSAN** wizard.

If the vSAN HCL configuration is compatible with the vSAN ESA cluster, vSAN ESA gets auto enabled.

4. Configure the vSAN services to use, and click **Next** .

  - Configure data management features, including deduplication and compression, data-at-rest encryption, data-intransit encryption.

  - Select Remote Direct Memory Access (RDMA) if your network supports it. For more information, see vSphere
RDMA.

  - Create and assign a default datastore policy for vSAN ESA. This auto-policy management allows best capacity
utilization after the cluster configuration is complete.

5. Claim disks for the vSAN cluster, and click **Next** .

  - For vSAN ESA, if the disks are compatible, the auto-claim get enabled. vSAN can claim all the eligible disks and
add additional hosts.

  - For vSAN OSA, each ESXi host that contribute storage requires at least one flash device for cache, and one or
more devices for capacity. For vSAN ESA, each ESXi host that contributes storage requires one or more flash
devices.

6. Create fault domains to groupESXi hosts that can fail together.

7. Review the configuration, and click **Finish** .


**View vSAN Datastore**

After you enable vSAN, a single datastore is created. You can review the capacity of the vSAN datastore. Configure vSAN
and disk groups or storage pools.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Monitor** tab.

3. Under vSAN, select **Capacity** .

vSAN provides the capacity overview of the vSAN datastore and the vSAN system overheads. For more information,
see Monitor vSAN Capacity.


**Using vSAN and vSphere HA**

You can enable vSphere HA and vSAN on the same cluster. vSphere HA provides the same level of protection for virtual
machines on vSAN datastores as it does on traditional datastores. This level of protection imposes specific restrictions
when vSphere HA and vSAN interact.


**ESXi Host Requirements**

You can use vSAN with a vSphere HA cluster only if the following conditions are met:

- The cluster's ESXi hosts all must be version 9.0 or later.


VMware by Broadcom 1689


VMware Cloud Foundation 9.0


- The cluster must have a minimum of three ESXi hosts, unless it is a vSAN two-host cluster. For best results, configure
the vSAN cluster with four or more hosts.

**Note:** vSAN supports Proactive HA. Select the following remediation method: **Maintenance mode for all failures** .
Quarantine mode is supported, but it does not protect against data loss if the host in quarantine mode fails, and there are
objects with FTT=0 or objects with FTT=1 that are degraded.


**Networking Differences**

vSAN uses its own logical network. When vSAN and vSphere HA are enabled for the same cluster, the HA interagent
traffic flows over this storage network rather than the management network. vSphere HA uses the management network
only when vSAN is turned off. vCenter chooses the appropriate network when vSphere HA is configured on a host.

**Note:** Make sure vSphere HA is not enabled when you enable vSAN on the cluster. Then you can re-enable vSphere HA.

When a virtual machine is only partially accessible in all network partitions, you cannot power on the virtual machine
or fully access it in any partition. For example, if you partition a cluster into P1 and P2, the VM namespace object is
accessible to the partition named P1 and not to P2. The VMDK is accessible to the partition named P2 and not to P1. In
such cases, the virtual machine cannot be powered on and it is not fully accessible in any partition .

The following table shows the differences in vSphere HA networking whether or not vSAN is used.


**Table 841: vSphere HA Networking Differences**






|Col1|vSAN On|vSAN Off|
|---|---|---|
|Network used by vSphere HA|vSAN storage network|Management network|
|Heartbeat datastores|Any datastore mounted to more than one<br>host, but not vSAN datastores|Any datastore mounted to more than one<br>host|
|Host declared isolated|Isolation addresses not pingable and vSAN<br>storage network inaccessible|Isolation addresses not pingable and<br>management network inaccessible|



If you change the vSAN network configuration, the vSphere HA agents do not automatically acquire the new network
settings. To change the vSAN network, you must re-enable host monitoring for the vSphere HA cluster:

1. Deactivate Host Monitoring for the vSphere HA cluster.
2. Make the vSAN network changes.
3. Right-click all hosts in the cluster and select **Reconfigure HA** .
4. Reactivate Host Monitoring for the vSphere HA cluster.

**Note:**

You can disable the default gateway by setting `das.usedefaultisolationaddresss` and
`das.isolationaddress0` [to an address on the vSAN network. For more information, see Using an Isolation address to](https://knowledge.broadcom.com/external/article/313763/using-an-isolation-address-to-ensure-ha.html)
[ensure HA functionality in a vSAN environment.](https://knowledge.broadcom.com/external/article/313763/using-an-isolation-address-to-ensure-ha.html)


**Capacity Reservation Settings**

When you reserve capacity for your vSphere HA cluster with an admission control policy, this setting must be coordinated
with the corresponding **Failures to tolerate** policy setting in the vSAN rule set. It must not be lower than the capacity
reserved by the vSphere HA admission control setting. For example, if the vSAN rule set allows for only two failures, the
vSphere HA admission control policy must reserve capacity that is equivalent to only one or two host failures. If you are
using the Percentage of Cluster Resources Reserved policy for a cluster that has eight hosts, you must not reserve more
than 25 percent of the cluster resources. In the same cluster, with the **Failures to tolerate** policy, the setting must not
be higher than two hosts. If vSphere HA reserves less capacity, failover activity might be unpredictable. Reserving too


VMware by Broadcom 1690


VMware Cloud Foundation 9.0


much capacity overly constrains the powering on of virtual machines and inter cluster vSphere vMotion migrations. For
[information about the Percentage of Cluster Resources Reserved policy, see the vSphere Availability guide.](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/vsphere-availability.html)


**vSAN and vSphere HA Behavior in a Multiple Host Failure**

After a vSAN cluster fails with a loss of failover quorum for a virtual machine object, vSphere HA might not be able to
restart the virtual machine even when the cluster quorum has been restored. vSphere HA guarantees the restart only
when it has a cluster quorum and can access the most recent copy of the virtual machine object. The most recent copy is
the last copy to be written.

Consider an example where a vSAN virtual machine is provisioned to tolerate one host failure. The virtual machine runs
on a vSAN cluster that includes three hosts, H1, H2, and H3. All three hosts fail in a sequence, with H3 being the last host
to fail.

After H1 and H2 recover, the cluster has a quorum (one host failure tolerated). Despite this quorum, vSphere HA is unable
to restart the virtual machine because the last host that failed (H3) contains the most recent copy of the virtual machine
object and is still inaccessible.

In this example, either all three hosts must recover at the same time, or the two-host quorum must include H3. If neither
condition is met, HA attempts to restart the virtual machine when host H3 is online again.


**Deploying vSAN with vCenter**

With vSphere Foundation 9.0, you can use an installer to deploy a vCenter instance and host the vCenter on that cluster.

When you use the vCenter installer, ensure that you do not select **Install on a new vSAN cluster** option. Follow the
steps in the installer wizard to complete the deployment. You can activate vSAN from the vSphere Client after deploying
vCenter. For more information on vSAN bootstrap not working with the installer, see Broadcom knowledge base article
[389238.](https://knowledge.broadcom.com/external/article?articleNumber=389238)


**Turn Off vSAN**

You can turn off vSAN for a vSphere cluster when the vCenter managing the vSphere cluster is deployed outside the
vSAN cluster.

- Disable vSphere High Availability (HA), if HA is enabled.

- Shutdown all the VMs, unless vCenter is on the cluster. If vCenter is on the cluster, you must migrate vCenter from the
cluster that you want to turn off.

- Verify that the ESXi hosts are in maintenance mode with 'No Data Migration' selected. For more information, see Place
a Member of vSAN Cluster in Maintenance Mode.

When you turn off vSAN for a cluster, all virtual machines and data services located on the vSAN datastore become
inaccessible. If you have consumed storage on the vSAN cluster using vSAN Direct, then the vSAN Direct monitoring
services, such as health checks, space reporting, and performance monitoring, are not available. If you intend to use
virtual machines while vSAN is off, make sure you migrate the virtual machines from vSAN datastore to another datastore
before turning off the vSAN cluster.


VMware by Broadcom 1691


VMware Cloud Foundation 9.0


1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, select **Services** .

4. Click **Turn Off** vSAN.

5. On the Turn Off vSAN dialog, confirm your selection.
### **Creating a vSAN Stretched Cluster or Two-Node vSAN Cluster**

You can create a vSAN stretched cluster that spans two availability zones. vSAN stretched clusters enable you to extend
the vSAN datastore across two availability zones to use it as stretched storage. The vSAN stretched cluster continues to
function if a failure or scheduled maintenance occurs at one zone.


**What Are vSAN Stretched Clusters**

vSAN stretched clusters extend the vSAN cluster from a single data site to two availability zones for a better level of
availability and intersite load balancing. vSAN stretched clusters are typically deployed in environments where the
distance between data centers is limited, such as metropolitan or campus environments.

You can use vSAN stretched clusters to manage planned maintenance and avoid disaster scenarios, because
maintenance or loss of one site does not affect the overall operation of the cluster. In a vSAN stretched cluster
configuration, both data sites are active sites. If either site fails, vSAN uses the storage on the other site. vSphere HA
restarts any VM that must be restarted on the remaining active site.

You must designate one site as the preferred site. The other site becomes a secondary or nonpreferred site. If the network
connection between the two active sites is lost, vSAN continues operation with the preferred site. The site designated as
preferred typically is the one that remains in operation, unless it is resyncing or has another issue. The site that leads to
maximum data availability is the one that remains in operation.

A vSAN stretched cluster can tolerate one intersite link failure at a time without data becoming unavailable. A link failure is
a loss of network connection between the two sites or between one site and the witness host. During a site failure or loss
of network connection, vSAN automatically switches to fully functional sites.

vSAN stretched clusters can tolerate a witness host failure when one site is unavailable. Configure the storage policy
Site disaster tolerance rule to Site mirroring - stretched cluster. If one site is down due to maintenance or failure and the
witness host fails, objects become non-compliant but remain accessible.

[For more information about working with vSAN stretched clusters, see the vSAN Stretched Cluster Guide.](https://www.vmware.com/docs/vsan-stretched-cluster-guide)


**Witness Host**

Each vSAN stretched cluster consists of two data sites and one witness host. The witness host resides at a third site
and contains the witness components of virtual machine objects. The witness host does not store customer data, only
metadata, such as the size and UUID of vSAN object and components.

The witness host serves as a tiebreaker when a decision must be made regarding availability of datastore components
when the network connection between the two availability zones is lost. In this case, the witness host forms a vSAN
cluster with the preferred site. But if the preferred site becomes isolated from the secondary site and the witness, the
witness host forms a cluster using the secondary site. When the preferred site is online again, data is resynchronized to
ensure that both sites have the latest copies of all data.

If the witness host fails, all corresponding objects become noncompliant but are fully accessible.

The witness host has the following characteristics:

- The witness host can use low bandwidth/high latency links.


VMware by Broadcom 1692


VMware Cloud Foundation 9.0


- The witness host cannot run virtual machines.

- A single witness host can support only one vSAN stretched cluster. Two-node vSAN clusters can share a single
witness host.

- The witness host must have one VMkernel adapter with vSAN traffic enabled, with connections to all hosts in the
cluster. The witness host uses one VMkernel adapter for management and one VMkernel adapter for vSAN data traffic.
The witness host can have only one VMkernel adapter dedicated to vSAN.

- The witness host must be a standalone host dedicated to the vSAN stretched cluster. It cannot be added to any other
cluster or moved in inventory through vCenter.

The witness host can be a physical host or an ESXi host running inside a VM. The VM witness host does not provide
other types of functionality, such as storing or running virtual machines. Multiple witness hosts can run as virtual machines
on a single physical server. For patching and basic networking and monitoring configuration, the VM witness host works in
the same way as a typical ESXi host. You can manage it with vCenter, patch it and update it by using `esxcli` or vSphere
Lifecycle Manager, and monitor it with standard tools that interact with ESXi hosts.

You can use a witness virtual appliance as the witness host in a vSAN stretched cluster. The witness virtual appliance
is an ESXi host in a VM, packaged as an OVF or OVA. The appliance is available in different options, based on the size
of the deployment. You can use a witness virtual appliance as the witness host in a vSAN stretched cluster. The witness
virtual appliance is an ESXi host in a VM, packaged as an OVF or OVA. Different appliances and different options are
available, based on the vSAN architecture and the size of the deployment.


**vSAN Stretched Clusters and Fault Domains**

vSAN stretched clusters use fault domains to provide redundancy and failure protection across sites. Each site in a vSAN
stretched cluster resides in a separate fault domain.

A vSAN stretched cluster requires three fault domains: the preferred site, the secondary site, and a witness host. Each
fault domain represents a separate site. When the witness host fails or enters maintenance mode, vSAN considers it a
site failure.

vSAN can provide an extra level of local fault protection for virtual machine objects in vSAN stretched clusters. When you
configure a vSAN stretched cluster, the following policy rules are available for objects in the cluster:




- **Site disaster tolerance** . For vSAN stretched clusters, this rule defines the failure tolerance method. Select **Site**
**mirroring - stretched cluster** .

- **Failures to tolerate (FTT)** . For vSAN stretched clusters, **FTT** defines the number of additional host failures that a
virtual machine object can tolerate.

- **None** . Configure vSAN Storage Policy for SMP-FT VMs.

 - vSAN stretched clusters support enabling Symmetric Multiprocessing Fault Tolerance (SMP-FT) VMs only when



site disaster tolerance storage policy is set to None with either Preferred or Secondary site. vSAN does not support
SMP-FT VMs on a stretched cluster when site disaster tolerance storage policy is set to Site mirroring - stretched
cluster.

- vSAN ROBO clusters support enabling Symmetric Multiprocessing Fault Tolerance (SMP-FT) with FTT set to 1 only



when both the data nodes are in the same physical site.



In a vSAN stretched cluster with local fault protection, even when one site is unavailable, the cluster can perform repairs
on missing or broken components in the available site.

vSAN continue to serve I/O if any disks or disks on one site reach 96 percent full or 5 GbE free capacity (whichever is
less) while disks on the other site have free space available. Components on the affected site are marked absent, and
vSAN continues to perform I/O to healthy object copies on the other site. When disks on the affected site disk reach 94
percent capacity or 10 GbE (whichever is less), the absent components become available. vSAN resyncs the available
components and all objects become policy compliant.


VMware by Broadcom 1693


VMware Cloud Foundation 9.0



**vSAN Stretched Cluster Design Considerations**


Consider these guidelines when working with a vSAN stretched cluster.




- Configure DRS settings for the vSAN stretched cluster.

 - DRS must be enabled on the cluster. If you place DRS in partially automated mode, you can control which virtual



machines to migrate to each site. vSAN enables you to operate DRS in automatic mode, and recover gracefully
from network partitions.

- Create two host groups, one for the preferred site and one for the secondary site. Associate the hosts in the vSAN



preferred fault domain to the preferred site host group, and associate the hosts in the vSAN secondary fault domain
to the secondary site host group.

- Create two VM groups, one to hold the virtual machines on the preferred site and one to hold the virtual machines



on the secondary site.

- Create two VM-Host affinity rules that map VMs-to-host groups, and specify which virtual machines and hosts



reside in the preferred site and which virtual machines and hosts reside in the secondary site.

 - Configure VM-Host affinity rules to perform the initial placement of virtual machines in the cluster.

- Configure HA settings for the vSAN stretched cluster.

 - HA rule settings should respect VM-Host affinity rules during failover.

 - Disable HA datastore heartbeats.

 - Use HA with Host Failure Monitoring, Admission Control, and set FTT to the number of hosts in each site.

- Configure a vSAN storage policy that has a stretched cluster site failure tolerance rule. With vSAN ESA and autopolicy management enabled, Broadcom recommends storage policies to optimize capacity utilization based on the
cluster size and topology.

- vSAN stretched clusters support enabling Symmetric Multiprocessing Fault Tolerance (SMP-FT) virtual machines only
when **Site Disaster Tolerance** is set to **None** with either Preferred or Secondary. vSAN does not support SMP-FT
virtual machines on a vSAN stretched cluster with **Site Disaster Tolerance** set to 1 or more. vSAN two-host clusters
support enabling SMP-FT with **FTT** set to 1 only when both data nodes are in the same site.

- When a host is disconnected or not responding, you cannot add or remove the witness host. This limitation ensures
that vSAN collects enough information from all hosts before initiating reconfiguration operations.

- Using `esxcli` to add or remove hosts is not supported for vSAN stretched clusters.

- Do not create snapshots of the witness host or backup the witness host. If the witness host fails, see Replace the
Witness Host.



[To learn how the stretched cluster storage policy rules impact the vSAN capacity requirements, see vSAN Stretched](https://www.vmware.com/docs/vsan-stretched-cluster-guide)
[Cluster Guide.](https://www.vmware.com/docs/vsan-stretched-cluster-guide)


**Best Practices for Working with vSAN Stretched Clusters**


When working with vSAN stretched clusters, follow these recommendations for proper performance.

- If one of the sites (fault domains) in a vSAN stretched cluster is inaccessible, new virtual machines can still be
provisioned in the subcluster containing the operational site. These new virtual machines are implicitly force
provisioned if at least two or three sites are available and are non-compliant until the partitioned site rejoins the cluster.
A site here refers to either a data site or the witness host. The objects have no failure tolerance and are susceptible
to data loss on any additional failure. They create new virtual machines only if necessary. With the vSAN 9.0 release,
the new virtual machines are created to comply with the lower failures to tolerate, specified in the policy. This improves
failure tolerance as the policy specifies a lower failures to tolerate of one or more.

- If an entire site goes offline due to a power outage or loss of network connection, restart the site immediately, without
much delay. Instead of restarting vSAN hosts one by one, bring all hosts online approximately at the same time, ideally
within a span of 10 minutes. By following this process, you avoid resynchronizing a large amount of data across the
sites.

- If a host is permanently unavailable, remove the host from the cluster before you perform any reconfiguration tasks.


VMware by Broadcom 1694


VMware Cloud Foundation 9.0


- If you want to clone a VM witness host to support multiple vSAN stretched clusters, do not configure the VM as a
witness host before cloning it. First deploy the VM from OVF, then clone the VM, and configure each clone as a
witness host for a different cluster. Or you can deploy as many virtual machines as you need from the OVF, and
configure each one as a witness host for a different cluster.


**vSAN Stretched Clusters Network Design**


All three sites in a vSAN stretched cluster communicate across the management network and across the vSAN network.
The virtual machines in both data sites communicate across a common virtual machine network.

A vSAN stretched cluster must meet certain basic networking requirements.

- Management network requires connectivity across all three sites, using a Layer 2 stretched network or a Layer 3
network.

- The vSAN network requires connectivity across all three sites. It must have independent routing and connectivity
between the data sites and the witness host. vSAN supports both Layer 2 and Layer 3 between the two data sites, and
Layer 3 between the data sites and the witness host.

- VM network requires connectivity between the data sites, but not the witness host. Use a Layer 2 stretched network or
Layer 3 network between the data sites. In the event of a failure, the virtual machines do not require a new IP address
to work on the remote site.

- vMotion network requires connectivity between the data sites, but not the witness host. Use a Layer 2 stretched or a
Layer 3 network between data sites.

**Note:**

vSAN over RDMA is not supported on vSAN stretched clusters or two-node vSAN clusters.


**Override Default Gateway for a vSAN VMKernel Adapater**

If you use a single default gateway on ESXi hosts, each ESXi host contains a default TCP/IP stack that has a single
default gateway. The default route is typically associated with the management network TCP/IP stack.

The management network and the vSAN network might be isolated from one another. For example, the management
network might use vmk0 on physical NIC 0, while the vSAN network uses vmk2 on physical NIC 1 (separate network
adapters for two distinct TCP/IP stacks). This configuration implies that the vSAN network has no default gateway.

You can override the default gateway for the vSAN VMkernel adapter on each host, and configure a gateway address
for the vSAN network. You can override the default gateway when the vSAN network uses a different subnet than the
management network. In vSAN stretched clusters, data sites and the witness hosts can reside on separate networks. A
dedicated vSAN gateway allows traffic to reach the witness host without static routes, simplifying network configuration.
[For more information on overriding default gateway, see Override the Default Gateway of VMKernel Adapter.](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/vsphere-networking/setting-up-vmkernel-networking/overriding-the-default-gateway-of-a-vmkernel-adapter.html)

You also can use static routes to communicate across networks. Consider a vSAN network that is stretched over two data
sites on a Layer 2 broadcast domain (for example, 172.10.0.0) and the witness host is on another broadcast domain (for
example, 172.30.0.0). If the VMkernel adapters on a data site try to connect to the vSAN network on the witness host, the
connection fails because the default gateway on the ESXi host is associated with the management network. There is no
route from the management network to the vSAN network.

Define a new routing entry that indicates which path to follow to reach a particular network. For a vSAN network on a
vSAN stretched cluster, you can add static routes to ensure proper communication across all hosts.

For example, you can add a static route to the hosts on each data site, so requests to reach the 172.30.0.0 witness
network are routed through the 172.10.0.0 interface. Also add a static route to the witness host so that requests to reach
the 172.10.0.0 network for the data sites are routed through the 172.30.0.0 interface.


VMware by Broadcom 1695


VMware Cloud Foundation 9.0


**Note:** If you use static routes, you must manually add the static routes for new ESXi hosts added to either site before
those hosts can communicate across the cluster. If you replace the witness host, you must update the static route
configuration.

Use the `esxcli network ip route` command to add static routes.


**What Are Two-Node vSAN Clusters**

A two-node vSAN cluster has two hosts at the same location. The witness function is performed at a second site on a
dedicated virtual appliance.

Two-node vSAN clusters are often used for remote office/branch office environments, typically running a small number of
workloads that require high availability. A two-node vSAN cluster consists of two hosts at the same location, connected to
the same network switch or directly connected. A third host acts as a witness host, which can be located remotely from
the branch office. Usually the witness host resides at the main site, with the vCenter.

A single witness host can support up to 64 two-node vSAN clusters. The number of clusters supported by a shared
witness host is based on the host memory.

When you configure a two-node vSAN cluster in Quickstart or with the Configure vSAN wizard, you can select a witness
host. To assign a new witness host for your cluster, right-click the cluster in the vSphere Client and select menu **vSAN** **Assign Shared Witness** .


**Use Quickstart to Configure a vSAN Stretched Cluster or Two-Node vSAN Cluster**

You can use the Quickstart workflow to quickly configure a vSAN stretched cluster or two-node vSAN cluster.

- Deploy a host outside of any cluster to use as a witness host.

- Verify that hosts are running ESXi 9.0 or later. For a two-node vSAN cluster, verify that hosts are running ESXi 9.0 or
later.

- Verify that ESXi hosts in the cluster do not have any existing vSAN or networking configuration.

When you create a cluster in the vSphere Client, the Quickstart workflow appears. You can use Quickstart to perform
basic configuration tasks, such as adding hosts and claiming disks.


VMware by Broadcom 1696


VMware Cloud Foundation 9.0


1. Navigate to the cluster in the vSphere Client.

2. Click the Configure tab, and select **Configuration** - **Quickstart** .

3. On the Cluster basics card, click **Edit** to open the Cluster basics wizard.

a) Enter the cluster name.
b) Enable the vSAN slider.

Select **vSAN ESA** if your cluster is compatible. You also can enable other features, such as DRS or vSphere HA.
c) Select any option to **Choose how to set up the cluster's image** .
d) (Optional) Select Manage configuration at a cluster level check box to ensure that all the hosts in the cluster have

the same settings.
e) Click **Next** .
f) Select an image from the Image Library of Lifecycle Manager.
g) Click **Next** and review the cluster details.
h) Click **Finish** .

4. On the Add hosts card, click **Add** to open the Add hosts wizard.

a) On the Add hosts page, enter information for new hosts, or click Existing hosts and select from hosts listed in the

inventory.
b) On the Host summary page, verify the host settings.
c) On the Ready to complete page, click **Finish** .

5. On the Cluster configuration card, click **Configure** to open the Cluster configuration wizard.

a) (vSAN ESA clusters) On the Cluster Type page, enter the HCI cluster type:

    - **vSAN HCI** provides compute resources and storage resources. The datastore can be shared across data
centers and vCenter instances.

    - **vSAN storage clusters** provides storage resources, but not compute resources. The datastore can be
mounted by remote vSAN clusters across data centers and vCenter instances.
b) On the Configure the distributed switches page, enter networking settings, including distributed switches, port

groups, and physical adapters.

    - In the **Distributed switches** section, enter the number of distributed switches to configure from the drop-down
menu. Enter a name for each distributed switch. Click **Use Existing** to select an existing distributed switch.
If the physical adapters chosen are attached to a standard virtual switch with the same name across hosts, the
standard switch is migrated to the distributed switch. If the physical adapters chosen are unused, the standard
switch is migrated to the distributed switch.
Network resource control is enabled and set to version 3. Distributed switches with network resource control
version 2 cannot be used.

    - In the **Port Groups** section, select a distributed switch to use for vMotion and a distributed switch to use for the
vSAN network.

    - In the **Physical adapters** section, select a distributed switch for each physical network adapter. You must
assign each distributed switch to at least one physical adapter.


VMware by Broadcom 1697


VMware Cloud Foundation 9.0


This mapping of physical NICs to the distributed switches is applied to all hosts in the cluster. If you are using
an existing distributed switch, the physical adapter selection can match the mapping of the distributed switch.
c) On the vMotion traffic page, enter IP address information for vMotion traffic.
d) On the Storage traffic page, enter IP address information for storage traffic.
e) On the Advanced options page, enter information for cluster settings, including DRS, HA, vSAN, host options, and

EVC.

In the **vSAN options** section, select vSAN Stretched cluster or Two node vSAN cluster as the **Deployment type** . If
you select vSAN Storage, you get the option to **Use Storage cluster client network** . Once configured, you cannot
change the network configuration.
f) On the Claim disks page, select storage devices to create the vSAN datastore.

For vSAN OSA, select devices for cache and for capacity. vSAN uses those devices to create disk groups on each
host.

For vSAN ESA, select compatible flash devices or enable **I want vSAN to manage the disks** . vSAN uses those
devices to create storage pools on each host.
g) (Optional) On the Proxy settings, page, configure the proxy server if your system uses one.
h) On the Configure fault domains page, define fault domains for the hosts in the Preferred site and the Secondary

site.

For more information about fault domains, see Managing Fault Domains in Clusters.
i) On the Select witness host page, select a host to use as a witness host. The witness host cannot be part of the
vSAN stretched cluster, and it can have only one VMkernel adapter configured for vSAN data traffic.
Before you configure the witness host, verify that it is empty and does not contain any components. A two-node
vSAN cluster can share a witness with other two-node vSAN clusters.
j) On the Claim disks for witness host page, select disks on the witness host.
k) On the Review page, verify the cluster settings, and click **Finish** .

You can manage the cluster through vCenter.

You can add hosts to the cluster and modify the configuration through Quickstart. You also can modify the configuration
manually with the vSphere Client.


**Manually Configure vSAN Stretched Cluster**

Configure a vSAN cluster that stretches across two geographic locations or sites.

- Verify that you have a minimum of three hosts: one for the preferred site, one for the secondary site, and one host to
act as a witness.

- Verify that you have configured one host to serve as the witness host for the vSAN stretched cluster. Verify that the
witness host is not part of the vSAN cluster, and that it has only one VMkernel adapter configured for vSAN data traffic.

- Verify that the witness host is empty and does not contain any components. To configure an existing vSAN host as a
witness host, first remove the witness from an existing two-node cluster or vSAN stretched cluster and remove any
vSAN disk groups or storage pools on the witness host.

1. Navigate to the vSAN cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Fault Domains** .

4. Click **Configure Stretched Cluster** to open the vSAN stretched cluster configuration wizard.

5. Select the hosts that you want to assign to the secondary fault domain and click **>>** .

The hosts that are listed under the Preferred fault domain are in the preferred site.


VMware by Broadcom 1698


VMware Cloud Foundation 9.0


6. Click **Next** .

7. Select a witness host that is not a member of the vSAN stretched cluster and click **Next** .

8. Claim storage devices on the witness host and click **Next** .

For vSAN OSA, select devices for cache and for capacity.

For vSAN ESA, select compatible flash devices or enable **I want vSAN to manage the disks** .

9. On the **Ready to complete** page, review the configuration and click **Finish** .


**Change the Preferred Fault Domain**

You can configure the Secondary site as the Preferred site. The current Preferred site becomes the Secondary site.

**Note:**

Objects with **Data locality=Preferred** policy setting always move to the Preferred fault domain. Objects with **Data**
**locality=Secondary** always move to the Secondary fault domain. If you change the Preferred domain to Secondary, and
the Secondary domain to Preferred, these objects move from one site to the other. This action might cause an increase
in resynchronization activity. To avoid unnecessary resynchronization, you can change the Data locality setting to **None**
before you swap the Preferred and Secondary domains. Once you swap the domains back, you can reset the Data
locality.

1. Navigate to the vSAN cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Fault Domains** .

4. Select the secondary fault domain and click the **Change Preferred Fault Domain** icon.

5. Click **Yes** or **Apply** to confirm.

The selected fault domain is marked as the preferred fault domain.


**Deploying a vSAN Witness Appliance**

Specific vSAN configurations, such as a stretched cluster, require a witness host. Instead of using a dedicated physical
ESXi host as a witness host, you can deploy the vSAN witness appliance. The appliance is a preconfigured virtual
machine that runs ESXi and is distributed as an OVA file.

You can cross-host the witness for multiple stretched clusters only if the clusters run in four geographical locations. vSAN
does not support cross-hosting with clusters available only in two locations.

Unlike a general purpose ESXi host, the witness appliance does not run virtual machines. Its only purpose is to serve as a
vSAN witness, and it can contain only witness components.

The workflow to deploy and configure the vSAN witness appliance includes this process.

When you deploy the vSAN witness appliance, you must configure the size of the witness supported by the vSAN
stretched cluster. Choose one of the following options:

- Tiny supports up to 750 components (10 virtual machines or fewer).
**Note:**

vSAN ESA does not support tiny witness appliance.

- Medium supports up to 21,833 components (500 virtual machines). As a shared witness, the Medium witness
appliance supports up to 21,000 components and up to 21 two-node vSAN clusters.

- Large supports up to 45,000 components (more than 500 virtual machines). As a shared witness, the Large witness
appliance supports up to 24,000 components and up to 24 two-node vSAN clusters.


VMware by Broadcom 1699


VMware Cloud Foundation 9.0


- Extra Large supports up to 64,000 components (more than 500 virtual machines). As a shared witness, the Extra
Large witness appliance supports up to 64,000 components and up to 64 two-node vSAN clusters.

**Note:**

These estimates are based on standard VM configurations. The number of components that make up a VM can vary,
depending on the number of virtual disks, policy settings, snapshot requirements, and so on. For more information about
[witness appliance sizing for two-node vSAN clusters, see the vSAN 2 Node Guide.](https://www.vmware.com/docs/vmw-vsan-2-node-cluster-guide)

You also must select a datastore for the vSAN witness appliance. You must deploy the witness appliance on a third site
independent of the two sites where it is intended to be stretched. The witness appliance must not share any physical
resources with either data sites.



1. Download the appliance from the Broadcom Support Portal. Ensure that you download the correct witness appliance



for vSAN ESA clusters and vSAN OSA clusters.
2. [Deploy the appliance to a vSAN host or cluster. For more information, see Deploy and Export OVF and OVA](https://techdocs.broadcom.com/bin/gethidpage?ux-context-string=vsphclient_027&appid=vsphere-9-0&language=&format=rendered)



[Templates in the](https://techdocs.broadcom.com/bin/gethidpage?ux-context-string=vsphclient_027&appid=vsphere-9-0&language=&format=rendered) _vSphere Virtual Machine Administration_ guide.
3. Specify a unique VM name and select a datacenter and folder to deploy the VM and click **Next** .
4. Select a cluster or ESXi host that acts as a compute resource to deploy the VM and click **Next** .
5. Review the details and click **Next** .
6. Read and accept the license agreement and click **Next**
7. Select medium, large, or extra large as the size of the vSAN witness appliance and click **Next** . When you deploy the



vSAN witness appliance, you must configure the size of the witness.
8. Select the virtual disk format and the VM storage policy.
9. Select the datastore of the vSAN witness appliance and click **Next** . You can batch configure or configure per disk



group, as required.
10. Browse and select the port group for the witness appliance management interface and a secondary port group for the



secondary network for vSAN VMKernel port. Click **Next** . Broadcom recommends setting the management network for
vSAN traffic.
**Note:**



If you select the management network for vSAN traffic, you do not require to configure the secondary network. The
secondary network port group can have the same name as the management network port group. If you are using the
secondary network for vSAN traffic, select an appropriate port group.
11. Perform the following to customize the vSAN witness appliance and click **Next** :



a. Set a root password for the vSAN witness appliance.
b. Select the adapter to tag vSAN traffic type. You can select the management network or the secondary network.



Broadcom recommends setting the management network for vSAN traffic. If you select the management network
for vSAN traffic, you do not require to configure the secondary network and network settings can remain blank.
c. Customize the network settings for the management network (vmk0). You can select DHCP or set a static IP



address. If you select DHCP, you can leave the management network settings blank.
d. Customise the network settings for the secondary network (vmk1), if required. You can use DHCP or set a static IP



address. If you select DHCP, you can leave the secondary network settings blank.
**Note:**



If you select the management network for vSAN traffic, you do not require to configure the secondary network and
the network settings can remain unset.
12. Review the details and click **Finish** . After deployment of the vSAN witness appliance, power on the witness VM.

You can use the management IP from the vSAN witness VM and add it as a standalone host in the vSAN streteched
cluster.


VMware by Broadcom 1700


VMware Cloud Foundation 9.0


**Set Up the vSAN Network on the Witness Appliance**


The vSAN witness appliance includes two preconfigured network adapters. You must change the configuration of the
second adapter so that the appliance can connect to the vSAN network.

1. Navigate to the virtual appliance that contains the witness host.

2. Right-click the appliance and select **Edit Settings** .

3. On the **Virtual Hardware** tab, expand the second Network adapter.

4. From the drop-down menu, select the vSAN port group and click **OK** .

You can use the first VMkernel interface for vSAN traffic when using witness traffic separation.

**Configure Management Network on the Witness Appliance**


Configure the witness appliance, so that it is reachable on the network.

By default, the appliance can automatically obtain networking parameters if your network includes a DHCP server. If not,
you must configure appropriate settings.

1. Power on your witness appliance and open its console.

Because your appliance is an ESXi host, you see the Direct Console User Interface (DCUI).

2. Press F2 and navigate to the Network Adapters page.

3. On the Network Adapters page, verify that at least one vmnic is selected for transport.

4. Configure the IPv4 parameters for the management network.

a) Navigate to the IPv4 Configuration section and change the default DHCP setting to static.
b) Enter the following settings:

    - IP address

    - Subnet mask

    - Default gateway

5. Configure DNS parameters.

  - Primary DNS server

  - Alternate DNS server

  - Hostname

**Configure Network Interface for Witness Traffic**


You can separate data traffic from witness traffic in two-node vSAN clusters and vSAN stretched clusters.




- Verify that the data site to witness traffic connection has a minimum bandwidth of 2 Mbps for every 1,000 vSAN
components.

- Verify the latency requirements:

 - Two-node vSAN clusters must have less than 500 ms RTT.

 - vSAN stretched clusters with less than 11 hosts per site must have less than 200 ms RTT.

 - vSAN stretched clusters with 11 or more hosts per site must have less than 100 ms RTT.

- Verify that the vSAN data connection meets the following requirements.

 - For hosts directly connected in a two-node vSAN cluster, use a 10 GbE direct connection between hosts. Hybrid



clusters also can use a 1 GbE crossover connection between hosts.

- For hosts connected to a switched infrastructure, use a 10 GbE shared connection (required for all-flash clusters),



or a 1 GbE dedicated connection.



VMware by Broadcom 1701


VMware Cloud Foundation 9.0


- Verify that data traffic and witness traffic use the same IP version.

vSAN data traffic requires a low-latency, high-bandwidth link. Witness traffic can use a high-latency, low-bandwidth and
routable link. To separate data traffic from witness traffic, you can configure a dedicated VMkernel network adapter for
vSAN witness traffic on each data host on both sites

You can add support for a direct network cross-connection to carry vSAN data traffic in a vSAN stretched cluster. You can
configure a separate network connection for witness traffic. On each data host in the cluster, configure the management
VMkernel network adapter to also carry witness traffic. Do not configure the witness traffic type on the witness host.

**Note:** Network Address Translation (NAT) is not supported between vSAN data hosts and the witness host.

1. In the vSphere Client, navigate to the host in the cluster.

2. Click the **Configure** tab.

3. Under **Networking**, click **VMkernel adapters** .

4.

Click and click **Edit** .

5. Select **vSAN Witness** to separate vSAN witness traffic from other traffic types such as vMotion and management

traffic.


The management VMkernel network interface is not selected for vSAN traffic. Do not re-enable the interface in the
vSphere Client.


**Replace the Witness Host**

You can replace or change the witness host for a vSAN stretched cluster.

Verify that the witness host is not in use by another cluster, has a VMkernel configured for vSAN traffic, and has no vSAN
partitions on its disks.

Change the ESXi host used as a witness host for your vSAN stretched cluster.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Fault Domains** .

4. Click the **Change** button. The Change Witness Host wizard opens.

5. Select a new host to use as a witness host, and click **Next** .

6. Claim disks on the new witness host, and click **Next** .

7. On the Ready to complete page, review the configuration, and click **Finish** .


**Convert a vSAN Stretched Cluster to a Single Site vSAN Cluster**

You can decommission a vSAN stretched cluster and convert it to a single site vSAN cluster.

- Back up all running virtual machines, and verify that all virtual machines are compliant with their current storage policy.

- Ensure that no health issues exist, and that all resync activities are complete.

- Change the associated storage policy to move all VM objects to one site. Use the Data locality rule to restrict virtual
machine objects to the selected site.


VMware by Broadcom 1702


VMware Cloud Foundation 9.0


- Replace the stretched cluster storage policies applied to the VMs with standard vSAN cluster policies or create a new
vSAN storage policy that you can apply to a standard vSAN cluster.

When you decommission a vSAN stretched cluster, you must manually delete the fault domain configuration and remove
the witness host. Because the witness host is not available, all witness components are missing for your virtual machines.
To ensure full availability for your virtual machines, repair the cluster objects immediately.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Fault Domains** .

4. Change the storage policy to the default vSAN storage policy.

5. Disable the vSAN stretched cluster.

a) Click **Disable** . The Remove Witness Host dialog opens.
b) Click **Remove** to confirm.

6. Remove the hosts available at the secondary site from the cluster.

7. Remove the fault domain configuration.

a) Select a fault domain, and choose menu **Actions > Delete** . Click **Yes** to confirm.
b) Select the other fault domain, and choose menu **Actions > Delete** . Click **Yes** to confirm.

8. Remove the witness host from inventory.

9. Repair the objects in the cluster.

a) Click the **Monitor** tab.
b) Under vSAN, click **Health** and click **vSAN object health** .
c) Click **Repair object immediately** .
vSAN recreates the witness components within the cluster.
### **Creating a Stretched Compute Cluster**

You can create a stretched compute cluster where compute resources are stretched across two geographic locations (or
sites).

Stretched compute clusters enable you to extend the compute resources, hosts, and workloads running on different sites
to work as a single cluster. The stretched compute cluster continues to function if a failure or scheduled maintenance
occurs at a site.


**What is a Stretched Compute Cluster?**

Stretched compute clusters are cluster with compute resources that are distributed across two different sites or data
centers. These clusters provide high availability, disaster recovery, and resource management by enabling the cluster to
operate in a stretched mode across the sites.

Each site has its fault domain. The fault domain in the stretched compute cluster groups host based on their location
and network topology. This ensures that the cluster operates optimally across sites. When configured with two distinct
fault domains, stretched compute cluster enters stretched mode allowing the cluster to span two locations and improve
redundancy.


**Stretched Compute Clusters and Fault Domains**

In a stretched compute cluster, the fault domain organizes the hosts based on the site attributes and the network
topologies. You can group hosts based on their physical location. This ensures that the compute resources are distributed
across different fault domains and helps you manage the workload during site failure.


VMware by Broadcom 1703


VMware Cloud Foundation 9.0


With hosts available in two sites, you can configure a stretched compute cluster. You can add additional hosts, as
required. Use **Disable stretched compute cluster** to disable stretched compute cluster that removes the sites and
converts a stretched compute cluster to a compute cluster.


**Stretched Compute Clusters Design Considerations**

Consider the following guidelines when working on a stretched compute cluster:

- Ensure that the hosts in a compute cluster are placed in separate sites.

- Allow only the stretched compute cluster to mount the datastores from a vSAN stretched cluster.


**Stretched Compute Clusters Network Design**

All the sites in a stretched compute cluster communicate across the management network and across the vSAN network.
The virtual machines in both the data sites communicate across a common virtual machine network.

A stretched compute cluster must meet certain basic networking requirements:

- Management network requires connectivity across all the sites, using a Layer 3 network.

- The vSAN network requires connectivity across all the sites of the server cluster.

- VM network requires connectivity between the data sites. Use a Layer 3 network between the data sites. In the event
of a failure, the virtual machines do not require a new IP address to work on the remote site.

- vMotion network requires connectivity between the data sites. Use a Layer 3 network between the data sites.


**Configure a Stretched Compute Cluster**

You can configure a stretched compute cluster from a vSphere cluster.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Services** .

4. Select **Compute Cluster** as an HCI configuration type.

5. Select **Configure a stretched compute cluster without vSAN datastore** as the deployment option.

6. Click **Configure** . The Configure Stretched Compute Cluster dialog opens.

7. Click and drag the hosts from the fault domain or use arrow keys to move hosts from one fault domain to the other.

You can rename the fault domain name, if required.

8. Click **Apply** .


**Convert a Compute Cluster to a Stretched Compute Cluster**

If you have an existing compute cluster, you can convert the compute cluster to a stretched compute cluster. Once
converted, the stretched compute cluster can mount remote datastores from a vSAN stretched cluster.


VMware by Broadcom 1704


VMware Cloud Foundation 9.0


1. In the vSphere Client, navigate to the existing compute cluster.

2. Click the **Configure** tab.

3. Under vSAN, select **Fault Domains** .

4. Click **Configure** to open the Configure Stretched Compute Cluster dialog.

5. Select the hosts that you want to be part of the first and the second fault domain. You can move hosts between fault

domains or rename the fault domain name.

6. Click **Apply** .


**Rename a Fault Domain in a Stretched Compute Cluster**

You can change the name of an existing fault domain in your stretched compute cluster.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Fault Domains** .

4. Select the fault domain and click the **Actions** icon on the right side of the fault domain.

5. Choose **Edit** and the Edit Fault Domain dialog opens.

6. Enter a new fault domain name and click **Apply** .

The new name appears for the fault domain.


**Move Host into Selected Fault Domain in a Stretched Compute Cluster**

You can move a host into a selected fault domain in the stretched compute cluster.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Fault Domains** .

4. Click the host of a fault domain that you want to move to another fault domain.

5. Click the Actions icon on the right side of the fault domain, and select **Move** .

The selected host moves to the fault domain.


**Disable a Stretched Compute Cluster**

Depending on your requirement, you can disable a stretched compute cluster.

If you disable a stretched compute cluster, you convert the cluster to a compute cluster.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, select **Fault Domains** .

4. Click **Disable Stretched Compute Cluster** to open the Disable stretched compute cluster dialog.

5. Click **Disable** .

When you disable a stretched compute cluster, the existing fault domains configuration on the cluster gets removed.


VMware by Broadcom 1705


VMware Cloud Foundation 9.0
## **Administering VMware vSAN**

_Administering VMware vSAN_ describes how to configure and manage a VMware [®] vSAN [™] cluster in a VMware vSphere [®]

environment. vSAN explains how to manage the local physical storage resources that serve as storage capacity devices
in a vSAN cluster, and how to define storage policies for virtual machines (VMs) deployed to vSAN datastores.


**Intended Audience**

This information is for experienced virtualization administrators who are familiar with virtualization technology, day-to-day
data center operations, and vSAN concepts. The information in this guide is written for experienced system administrators
who are familiar with virtual machine technology and virtual datacenter operations. This manual assumes familiarity with
VMware vSphere, including VMware ESXi, vCenter and the vSphere Client.

- For more information about network requirements and network design, see the Designing vSAN Network guide.

- For more information about creating vSAN clusters, see the Planning and Configuring vSAN guide.

- For more information about monitoring a vSAN cluster and fixing problems, see the Monitoring and Troubleshooting
vSAN guide.
### **Managing a vSAN Cluster**

You can manage a vSAN cluster by using the vSphere Client, esxcli commands, vSphere PowerCLI, and other tools.


**Upload Files or Folders to vSAN Datastores**

You can upload vmdk files to a vSAN datastore.

[You can also upload folders to a vSAN datastore. For more information about datastores, see the vSphere Storage guide.](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/vsphere-storage.html)
When you upload a vmdk file to a vSAN datastore, the following considerations apply:

- You can upload only stream-optimized vmdk files to a vSAN datastore. VMware stream-optimized file format is a
monolithic sparse format compressed for streaming. If you want to upload a vmdk file that is not in stream-optimized
format, then, before uploading, convert it to stream-optimized format using the vmware-vdiskmanager command-line
[utility. For more information, see Virtual Disk Development Kit (VDDK) Programming Guide.](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere-sdks-tools/9-0/virtual-disk-development-kit-programming-guide.html)

- When you upload a vmdk file to a vSAN datastore, the vmdk file inherits the default policy of that datastore. The vmdk
does not inherit the policy of the virtual machine from which it was downloaded. vSAN creates the objects by applying
the vsanDatastore default policy. You can change the default policy of the datastore. See Change the Default Storage
Policy for vSAN Datastores.

- You must upload a vmdk file to virtual machine home folder.

1. In the vSphere Client, navigate to the vSAN datastore.

|Click the Files tab. Option|Description|
|---|---|
|**Option**<br>|**Description**<br><br>|
|**Upload Files**<br>|1.<br>Select the target folder and click**Upload Files**. You see a<br>message informing that you can upload vmdk files only in<br>VMware stream-optimized format. If you try uploading a<br>vmdk file in a different format, you see an internal server<br>error message.<br>2.<br>Click**Upload**.<br>3.<br>Locate the item to upload on the local computer and click<br>**Open**.<br><br>|
|**Upload Folder**|1.<br>Select the target folder and click**Upload Folder**. You see<br>a message informing that you can upload vmdk files only in<br>VMware stream optimized format.<br>2.<br>Click**Upload**.|



VMware by Broadcom 1706


VMware Cloud Foundation 9.0

|Option|Description|
|---|---|
||3.<br>Locate the item to upload on the local computer and click<br>**Upload**.|



**Download Files or Folders from vSAN Datastores**

You can download files and folders from a vSAN datastore.

The vmdk files are downloaded as stream-optimized files with the filename `<vmdkName>_stream.vmdk` . VMware
stream-optimized file format is a monolithic sparse format compressed for streaming.

You can convert a VMware stream-optimized vmdk file to other vmdk file formats using the vmware-vdiskmanager
[command-line utility. For more information, see Virtual Disk Development Kit (VDDK) Programming Guide.](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere-sdks-tools/9-0/virtual-disk-development-kit-programming-guide.html)

1. In the vSphere Client, navigate to the vSAN datastore.



2. Click the **Files** tab, select the file and then click **Download** . Ensure that the popups are enabled before you download



the file.
You see a message alerting you that vmdk files are downloaded from the vSAN datastores in VMware streamoptimized format with the filename extension `.stream.vmdk` .


### **Using vSAN Policies**



When you use vSAN, you can define virtual machine storage requirements, such as performance and availability, in a
policy.

In most cases, vSAN ensures that each virtual machine deployed to vSAN datastores is assigned at least one storage
policy. After they are assigned, the storage policy requirements are pushed to the vSAN layer when a virtual machine
is created. The virtual device is distributed across the vSAN datastore to meet the performance and availability
requirements.

vSAN uses VASA storage provider to supply information about underlying storage to the vCenter. This information helps
you to make appropriate decisions about virtual machine placement, and to monitor your storage environment.


**What are vSAN Policies**

vSAN storage policies define storage requirements for your VMs.

These policies determine how the virtual machine storage objects are provisioned and allocated within the datastore
to guarantee the required level of service. When you enable vSAN on a ESXi host cluster, a single vSAN datastore is
created and a default storage policy is assigned to the datastore.

When you know the storage requirements of your VMs, you can create a storage policy referencing capabilities that the
datastore advertises. You can create several policies to capture different types or classes of requirements.

Each virtual machine deployed to vSAN datastores is assigned at least one virtual machine storage policy. You can assign
storage policies when you create or edit VMs.

**Note:** If you do not assign a storage policy to a virtual machine, vSAN assigns a default policy. The default policy has
**Failures to tolerate** set to 1, a single disk stripe per object, and a thin-provisioned virtual disk.

The virtual machine swap object and the virtual machine snapshot memory object adhere to the storage policies assigned
to a virtual machine, with **Failures to tolerate** set to 1. They might not have the same availability as other objects that
have been assigned a policy with a different value for **Failures to tolerate** .

**Note:**

If vSAN ESA is enabled, every snapshot is not a new object. A base VMDK and its snapshots are contained in one vSAN
object. A data digest disk is a file that stores data digests for a specific VM or virtual disk. This digest file is used by the


VMware by Broadcom 1707


VMware Cloud Foundation 9.0


CBRC (Content Based Read Cache) mechanism to improve performance, especially during read-intensive operations like
boot storms or antivirus scans. It effectively acts as an index of the data on the virtual disk. This allows to quickly identify
and access specific data blocks. In vSAN ESA, data digest disk is backed by vSAN object.

In vSAN OSA, snapshots are separate vSAN objects. The data digest disks are separate objects in vSAN ESA and vSAN
OSA.


**Table 842: Storage Policy - Availability**

|Capability|Description|
|---|---|
|Site disaster tolerance|This rule defines whether to use a standard, stretched, or 2-node cluster. If you use<br>a vSAN stretched cluster, you can define whether data is mirrored at both sites or<br>only at one site. For a vSAN stretched cluster, you can choose to keep data on the<br>preferred or secondary site for affinity with a site or location.<br>•<br>**None - standard cluster** is the default value. This means that there is no site<br>disaster tolerance.<br>•<br>**Host mirroring - 2 node cluster** defines the number of additional failures that<br>an object can tolerate after the number of failures defined by FTT is reached.<br>vSAN performs object mirroring at the disk group level. Each data host must<br>have at least three disk groups or three disks in a storage pool to use this rule.<br>•<br>**Site mirroring - stretched cluster** defines the number of additional host<br>failures that an object can tolerate after the number of failures defined by FTT is<br>reached.<br>•<br>**None - keep data on Preferred (stretched cluster)**. If you do not want the<br>objects in a vSAN stretched cluster to have site failure tolerance and you want<br>to make the objects accessible only on the site that is configured as Preferred,<br>use this option.<br>•<br>**None - keep data on Secondary (stretched cluster)**. If you do not want the<br>objects in a vSAN stretched cluster to have site failure tolerance and you want<br>to make the objects accessible only on the secondary site, use this option.<br>These objects are not affected by the Inter-Switch Link (ISL) or witness host<br>failures. They remain accessible if the site chosen by the policy is accessible.|
|Failures to tolerate (FTT)|Defines the number of ESXi host and device failures that a virtual machine object<br>can tolerate. For`n` failures tolerated, each piece of data written is stored in`n+1`<br>places, including parity copies if using RAID-5 or RAID-6.<br>If fault domains are configured,`2n+1` fault domains with ESXi hosts contributing<br>capacity are required. An ESXi host which does not belong to a fault domain is<br>considered its own single-host fault domain.<br>You can select a data replication method that optimizes for performance or<br>capacity. RAID-1 (Mirroring) uses more disk space to place the components of<br>objects but provides better performance for accessing the objects. RAID-5/6<br>(Erasure Coding) uses less disk space, but performance is reduced. You can select<br>one of the following options:<br>•<br>**No data redundancy**: Specify this option if you do not want vSAN to protect<br>a single mirror copy of virtual machine objects. This means that your data is<br>unprotected, and you might lose data when the vSAN cluster encounters a<br>device failure. The ESXi host might experience unusual delays when entering<br>maintenance mode. The delays occur because vSAN must evacuate the object<br>from the host for the maintenance operation to complete successfully.<br>•<br>**1 failure - RAID-1 (Mirroring)**: Specify this option if your virtual machine object<br>can tolerate one ESXi host or device failure. To protect a 100 GbE virtual<br>machine object by using RAID-1 (Mirroring) with an FTT of 1, you consume 200<br>GB.|



VMware by Broadcom 1708


VMware Cloud Foundation 9.0

|Capability|Description|
|---|---|
||~~•~~<br>**1 failure - RAID-5 (Erasure Coding)**: Specify this option if your virtual machine<br>object can tolerate one ESXi host or device failure. For vSAN OSA, to protect a<br>100 GB virtual machine object by using RAID-5 (Erasure Coding) with an FTT<br>of 1, you consume 133.33 GB.<br>**Note:**<br>•<br>If you use vSAN ESA, vSAN creates an optimized RAID-5 format based on<br>the cluster size.<br>•<br>If the number of hosts in the cluster is less than 6, vSAN creates a RAID-5<br>(2+1) format.<br>•<br>If the number of ESXi hosts is equal or greater than 6, vSAN creates a<br>RAID-5 (4+1) format.<br>•<br>When the cluster size eventually expands or shrinks, vSAN automatically<br>readjusts the format after 24 hours from the configuration change.<br>•<br>**2 failures - RAID-1 (Mirroring)**: Specify this option if your virtual machine<br>object can tolerate up to two device failures. Since you need to have an FTT<br>of 2 using RAID-1 (Mirroring), there is a capacity overhead. To protect a 100<br>GbE virtual machine object by using RAID-1(Mirroring) with an FTT of 2, you<br>consume 300 GbE.<br>•<br>**2 failures - RAID-6 (Erasure Coding)**: Specify this option if your virtual<br>machine objects can tolerate up to one ESXi host or device failure. To protect<br>a 100 GbE virtual machine object by using R AID-6 (Erasure Coding) with an<br>FTT of 2, you consume 150 Gb. For more information, refer toUsing RAID 5 or<br>RAID 6 Erasure Coding in vSAN Cluster.<br>•<br>**3 failures - RAID-1 (Mirroring)**: Specify this option if your virtual machine<br>objects can tolerate up to three ESXi host or device failures. To protect a 100<br>GbE virtual machine object by using RAID-1 (Mirroring) with an FTT of 3, you<br>consume 400 GbE.<br>**Note:**<br>If you create a storage policy and you do not specify a value for**FTT**, vSAN creates<br>a single mirror copy of the virtual machine objects. It can tolerate a single failure.<br>However, if multiple component failures occur, your data might be at risk.|



**Table 843: Storage Policy - Storage rules**

|Capability|Description|
|---|---|
|Encryption services|Defines the encryption options ensuring that only datastores that matches the<br>selected options remain compliant. Choose one of the following options:<br>•<br>**Data-at-rest encryption**: Specify this option if the datastore that match the<br>policy attributes are available to provision the VMs.<br>•<br>**No encryption**: Specify this option if you do not want datastores with data-at-<br>rest encryption to match the policy.<br>•<br>**No preference**: This is the default option. Specify this option if you do not want<br>to explicitly apply any encryption rules. By selecting this option, vSAN applies<br>both rules to your VMs.|
|Space efficiency|Defines the space efficiency options ensuring that only datastores that matches the<br>selected options remain compliant. Choose one of the following options:<br>•<br>**Deduplication and compression**: Specify this option if the datastore that<br>match the policy attributes are available to provision the VMs.|



VMware by Broadcom 1709


VMware Cloud Foundation 9.0

|Capability|Description|
|---|---|
||~~•~~<br>**Compression only**: Specify this option if you do not want datastores with<br>deduplication and compression to match the policy.<br>**Note:**<br>For vSAN OSA, compression is a cluster-level setting. For vSAN ESA,<br>compression only is performed at the object level and is enabled by default on a<br>storage policy. This means that you can use compression for one vSAN object<br>but not for another vSAN object in the same vSAN cluster.<br>•<br>**No space efficiency**: Specify this option if you do not want to apply<br>compression to your objects.<br>•<br>**No preference**: This is the default option. Specify this option if you do not want<br>to explicitly apply any space efficiency rules. By selecting this option, vSAN<br>applies all space efficiency rules to your VMs.|
|Storage tier|Specify the storage tier for all VMs with the defined storage policy. Choose one of<br>the following options:<br>•<br>**All flash**: Specify this option if you want to make your VMs compatible with all-<br>flash environment.<br>•<br>**Hybrid**: Specify this option if you want to make your VMs compatible with only<br>hybrid environment.<br>•<br>**No preference**: This is the default option. Specify this option if you do not want<br>to explicitly apply any storage tier rules. By selecting this option, vSAN makes<br>the VMs compatible with both hybrid and all flash environments.|



**Table 844: Storage Policy - Advanced Policy Rules**

|Capability|Description|
|---|---|
|Number of disk stripes per object|The minimum number of capacity devices across which each replica of a virtual<br>machine object is striped. A value higher than 1 might result in better performance,<br>but also results in higher use of system resources.<br>Default value is 1. Maximum value is 12.<br>Do not change the default striping value.<br>In a hybrid environment, the disk stripes are spread across magnetic disks. For an<br>all-flash configuration, the striping is across flash devices that make up the capacity<br>layer. Make sure that your vSAN environment has sufficient capacity devices<br>present to accommodate the request.|
|IOPS limit for object|Defines the IOPS limit for an object, such as a VMDK. IOPS is calculated as the<br>number of I/O operations, using a weighted size. If the system uses the default<br>base size of 32 KB, a 64-KB I/O represents two I/O operations.<br>When calculating IOPS, read and write are considered equivalent, but cache hit<br>ratio and sequentiality are not considered. If a disk’s IOPS exceeds the limit, I/O<br>operations are throttled. If the**IOPS limit for object** is set to 0, IOPS limits are not<br>enforced.|
|Object space reservation|Percentage of the logical size of the virtual machine disk (vmdk) object that must<br>be reserved, or thick provisioned when deploying VMs. The following options are<br>available:<br>•<br>Thin provisioning (default)<br>•<br>25% reservation<br>•<br>50% reservation<br>•<br>75% reservation|



VMware by Broadcom 1710


VMware Cloud Foundation 9.0

|Capability|Description|
|---|---|
||~~•~~<br>Thick provisioning<br>**Note:**<br>If you select thick provisioning, the deduplication and compression savings<br>become ineffective.|
|Flash read cache reservation (%)|Flash capacity reserved as read cache for the virtual machine object. Specified<br>as a percentage of the logical size of the VM disk (vmdk) object. Reserved flash<br>capacity cannot be used by other objects. Unreserved flash is shared fairly among<br>all objects. Use this option only to address specific performance issues.<br>You do not have to set a reservation to get cache. Setting read cache reservations<br>might cause a problem when you move the VM object because the cache<br>reservation settings are always included with the object.<br>The Flash Read Cache Reservation storage policy attribute is supported only for<br>hybrid storage configurations. vSAN does not support this attribute for a vSAN OSA<br>all-flash cluster or for a vSAN ESA cluster.<br>Default value is 0%. Maximum value is 100%.<br>**Note:** By default, vSAN dynamically allocates read cache to storage objects based<br>on demand. This feature represents the most flexible and the most optimal use of<br>resources. As a result, typically, you do not need to change the default 0 value for<br>this parameter.<br>To increase the value when solving a performance problem, exercise caution. Over-<br>provisioned cache reservations across several VMs can cause flash device space<br>to be wasted on over-reservations. These cache reservations are not available to<br>service the workloads that need the required space at a given time. This space<br>wasting and unavailability might lead to performance degradation.|
|Disable Object Checksum|If the option is set to**No**, the object calculates checksum information to ensure<br>the integrity of its data. If this option is set to**Yes**, the object does not calculate<br>checksum information.<br>vSAN uses end-to-end checksum to ensure the integrity of data by confirming that<br>each copy of a file is exactly the same as the source file. The system checks the<br>validity of the data during read/write operations, and if an error is detected, vSAN<br>repairs the data or reports the error.<br>If a checksum mismatch is detected, vSAN automatically repairs the data by<br>overwriting the incorrect data with the correct data. Checksum calculation and<br>error-correction are performed as background operations.<br>The default setting for all objects in the cluster is**No**, which means that checksum<br>is enabled.<br>**Note:**<br>For vSAN ESA, object checksum is always on and cannot be deactivated.<br>For vSAN OSA, it is recommended to enable object checksum.|
|Force provisioning|If the option is set to**Yes**, the object is provisioned even if the**Failures to tolerate**,<br>**Number of disk stripes per object**, and**Flash read cache reservation** policies<br>specified in the storage policy cannot be satisfied by the datastore. Use this<br>parameter in bootstrapping scenarios and during an outage when standard<br>provisioning is no longer possible.<br>The default**No** is acceptable for most production environments. vSAN fails to<br>provision a virtual machine when the policy requirements are not met.|



When working with virtual machine storage policies, you must understand how the storage capabilities affect the
consumption of storage capacity in the vSAN cluster. For more information about designing and sizing considerations of
storage policies, refer to Designing and Sizing a vSAN Cluster.


VMware by Broadcom 1711


VMware Cloud Foundation 9.0


**How vSAN Manages Policy Changes**

Transient capacity is generated when vSAN reconfigures objects for a policy change. The transient storage activities
include vSAN disk rebalancing and object conversions.

When you modify a policy, the change is accepted but not applied immediately. vSAN batches the policy change requests
and performs them asynchronously, to maintain a fixed amount of transient space.

Policy changes are rejected immediately due to policy compliance and the underlying capabilities of the storage, such as
changing a RAID-5 policy to RAID-6 on a five-host cluster. vSAN storage policy compares the rules associated with the
policy and evaluates the underlying storage capabilities to determine whether the vSAN storage is compatible.

You can view transient capacity usage in the vSAN Capacity monitor ( **Cluster** - **Monitor** - **vSAN** - **Capacity** - **Capacity**
**Usage** - **Usage breakdown** - **System usage** ). To verify the status of a policy change on an object, use the vSAN health
service to check the vSAN object health.


**View vSAN Storage Providers**

Enabling vSAN automatically configures and registers a vSAN storage provider in the vSAN cluster.

vSAN storage providers are built-in software components that communicate datastore capabilities to vCenter. A storage
capability typically is represented by a key-value pair, where the key is a specific property offered by the datastore. The
value is a number or range that the datastore can provide for a provisioned object, such as a virtual machine home
namespace object or a virtual disk. You can also use tags to create user-defined storage capabilities and reference them
when defining a storage policy for a virtual machine.

1. In the vSphere Client, navigate to vCenter.

2. Click the **Configure** tab, and click **Storage Providers** .


The storage provider for vSAN appears on the list.

**Note:**

You cannot manually unregister storage providers used by vSAN. To remove or unregister the vSAN storage providers,
remove corresponding ESXi hosts from the vSAN cluster and then add the ESXi hosts back. Make sure that at least one
storage provider is active.


**What are vSAN Default Storage Policies**

vSAN requires that the virtual machines deployed on the vSAN datastores are assigned at least one storage policy.

When provisioning a virtual machine, if you do not explicitly assign a storage policy, vSAN assigns a default storage
policy to the virtual machine. Each default policy contains vSAN rule sets and a set of basic storage capabilities, typically
used for the placement of virtual machines deployed on vSAN datastores. If vSAN does not assign a storage policy to
the virtual machine, vSAN health check prompts a warning to reapply the VM storage policy. For more information, see
[Broadcom knowledge base article 326534.](https://knowledge.broadcom.com/external/article/326534/vsan-health-service-vsan-storage-policy.html)

If you use a vSAN ESA cluster, depending on your cluster size, you can use one of the vSAN ESA policies listed here.

**Note:**

The objects in a vSAN ESA cluster with RAID 0 or RAID 1 configuration have 3 disk stripes, though the default storage
policy defines only 1 disk stripe.


VMware by Broadcom 1712


VMware Cloud Foundation 9.0



**Table 845: vSAN ESA Default Storage Policy Specifications - RAID-5**







|Specification|Setting|
|---|---|
|Failures to tolerate|1|
|Number of disk stripes per object|1|
|Flash read cache reservation, or flash capacity used for the read<br>cache|0|
|Object space reservation|Thin provisioning|
|Force provisioning|No|


**Note:**

RAID-5 in vSAN ESA supports three ESXi host clusters. If you enable auto-policy management, the cluster must have
four ESXi hosts to use RAID-5.


**Table 846: vSAN ESA Default Storage Policy Specifications - RAID-6**







|Specification|Setting|
|---|---|
|Failures to tolerate|2|
|Number of disk stripes per object|1|
|Flash read cache reservation, or flash capacity used for the read<br>cache|0|
|Object space reservation|Thin provisioning|
|Force provisioning|No|


**Note:**

If you enable auto-policy management, the cluster must have six ESXi hosts to use RAID-6.


**Table 847: vSAN Default Storage Policy Specifications**







|Specification|Setting|
|---|---|
|Failures to tolerate|1|
|Number of disk stripes per object<br>**Note:**<br>In some cases, vSAN also applies a stripe.|1|
|Flash read cache reservation, or flash capacity used for the read<br>cache|0|
|Object space reservation|0<br>**Note:**<br>Setting the Object space reservation to zero means that the virtual<br>disk is thin provisioned, by default.|
|Force provisioning|No|


You can review the configuration settings for the default virtual machine storage policy when you navigate to the **VM**
**Storage Policies** - name of the default storage policy > **Rule-Set 1: VSAN** .


VMware by Broadcom 1713


VMware Cloud Foundation 9.0


For best results, consider creating and using your own virtual machine storage policies, even if the requirements of the
policy are same as those defined in the default storage policy.

When you assign a user-defined storage policy to a datastore, vSAN applies the settings for the user-defined policy on the
specified datastore. Only one storage policy can be the default policy for the vSAN datastore.


**Auto-Policy Management**

Clusters with vSAN ESA can use auto-policy management to generate an optimal default storage policy, based on the
cluster type (standard or stretched) and the number of ESXi hosts. vSAN configures the **Site disaster tolerance** and
**Failures to tolerate** to optimal settings for the cluster.

The name of the auto-generated policy is based on the cluster name, as follows: _ClusterName - Optimal Default Datastore_
_Policy_

When you enable auto-policy management, vSAN assigns a new optimal policy to the vSAN datastore, and that policy
becomes the datastore default policy for the cluster.

To enable auto-policy management, use the slide control on vSAN **> Services > Storage > Edit** .


**vSAN Default Storage Policy Characteristics**

The following characteristics apply to the vSAN datastore default storage policies.

- The vSAN Default Storage Policy is assigned to all virtual machine objects if you do not assign any other vSAN policy
when you provision a virtual machine. The **VM Storage Policy** text box is set to **Datastore default** on the **Select**
**Storage** page. For more information about using storage policies, see the _[vSphere Storage](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/vsphere-storage.html)_ guide.
**Note:**

Virtual machine swap and virtual machine memory objects receive a vSAN default storage policy with **Force**
**provisioning** set to **Yes** .

- A vSAN default policy only applies to vSAN datastores. You cannot apply a default storage policy to non- vSAN
datastores, such as NFS or a VMFS datastore.

- Objects in a vSAN ESA cluster with RAID 0 or RAID 1 configuration will have 3 disk stripes, even if the default policy
defines only 1 disk stripe.

- Because the **vSAN Default Storage Policy** is compatible with any vSAN datastore in the vCenter, you can move your
virtual machine objects provisioned with the default policy to any vSAN datastore in the vCenter.

- You can clone the vSAN Default Storage Policy and use it as a template to create a user-defined storage policy.

- You can edit the vSAN Default Storage Policy, if you have the _StorageProfile.View_ privilege. You must have at least
one vSAN-enabled cluster that contains at least one ESXi host. Typically you do not edit the settings of the vSAN
Default Storage Policy.

- You cannot edit the name and description of the vSAN Default Storage Policy, or the vSAN storage provider
specification. All other parameters including the policy rules are editable.

- You cannot delete the vSAN Default Storage Policy.

- A default storage policy is assigned when the policy that you assign during virtual machine provisioning does not
include rules specific to vSAN.


**Change the Default Storage Policy for vSAN Datastores**

You can change the default storage policy for a selected vSAN datastore.

Verify that the virtual machine storage policy you want to assign as the default policy to the vSAN datastore meets the
requirements of virtual machines in the vSAN cluster.


VMware by Broadcom 1714


VMware Cloud Foundation 9.0


1. In the vSphere Client, navigate to the vSAN datastore.

2. Click the **Configure** tab.

3. Under **General**, click the **Default Storage Policy Edit** button, and select the storage policy that you want to assign as

the default policy to the vSAN datastore.

**Note:**

You can also edit the Improved Virtual Disk Home Storage Policy. Click **Edit** and select the home storage policy that
you want to assign as the storage policy for the home object.

You can choose from a list of storage policies that are compatible with the vSAN datastore, such as the vSAN Default
Storage Policy and user-defined storage policies that have vSAN rule sets defined.

4. Click **OK** . The storage policy is applied as the default policy when you provision new virtual machines without explicitly

specifying a storage policy for a datastore.

You can define a new storage policy for virtual machines. See Define a Storage Policy for vSAN Using vSphere Client.


**Define a Storage Policy for vSAN Using vSphere Client**

You can create a storage policy that defines storage requirements for a virtual machine and its virtual disks.

- Verify that the vSAN storage provider is available. Refer to View vSAN Storage Providers.

- Required privileges: **Profile-driven storage.Profile-driven storage view** and **Profile-driven storage.Profile-driven**
**storage update**

In this policy, you reference the storage capabilities supported by the vSAN datastore.


VMware by Broadcom 1715


VMware Cloud Foundation 9.0


1. Navigate to **Policies and Profiles**, then click **VM Storage Policies** in the vSphere Client.

2. Click **Create** .

3. On the **Name and description** page, select a vCenter.

4. Type a name and a description for the storage policy and click **Next** .

5. On the **Policy structure** page, select **Enable rules for vSAN storage**, and click **Next** .

6. On the vSAN page, define the policy rule set, and click **Next** .

a) On the **Availability** tab, define the **Site disaster tolerance** and **Failures to tolerate** .

Availability options define the rules for failures to tolerate, data locality, and failure tolerance method.

    - **Site disaster tolerance** defines the type of site failure tolerance used for virtual machine objects.

    - **Failures to tolerate** defines the number of ESXi host and device failures that a virtual machine object can
tolerate, and the data replication method.

For example, if you choose **Dual site mirroring** and **2 failures - RAID-6 (Erasure Coding)**, vSAN configures the
following policy rules:

    - Failures to tolerate: 1

    - Secondary level of failures to tolerate: 2

    - Data locality: None

    - Failure tolerance method: RAID-5/6 (Erasure Coding) - Capacity
b) On the **Storage Rules** tab, define the encryption, space efficiency, and storage tier rules that can be used along

with the vSAN HCI Datastore Sharing to distinguish the remote datastores.




- **Encryption services** : Defines the encryption rules for virtual machines that you deploy with this policy. You can
choose one of the following options:

 - **Data-at-rest encryption** : Encryption is enabled on the virtual machines.

 - **No encryption** : Encryption is not enabled on the virtual machines.

 - **No preference** : Makes the virtual machines compatible with both data-at-rest encryption and No encryption



options.

- **Space Efficiency** : Defines the space saving rules for the virtual machines that you deploy with this policy. You
can choose one of the following options:

 - **Deduplication and compression** : Enables both deduplication and compression on the virtual machines.



Deduplication and compression are available only on all-flash disk groups. For more information, see
Deduplication and Compression Design Considerations in a vSAN Cluster.

- **Compression only** : Enables only compression on the virtual machines. Compression is available only on



all-flash disk groups. For vSAN ESA compression is defined in the vSAN policy.

- **No space efficiency** : Space efficiency features are not enabled on the virtual machines. Choosing this



option requires datastores without any space efficiency options to be turned on.

 - **No preference** : Makes the virtual machines compatible with all the options.

- **Storage tier** : Specifies the storage tier for the virtual machines that you deploy with this policy. You can choose
one of the following options. Choosing the **No preference** option makes the virtual machines compatible with
both hybrid and all flash environments.

 - **All flash**



VMware by Broadcom 1716


VMware Cloud Foundation 9.0


    - **Hybrid**

    - **No preference**
c) On the **Advanced Policy Rules** tab, define advanced policy rules, such as number of disk stripes per object and

IOPS limits.
d) On the **Tags** tab, click **Add Tag Rule**, and define the options for your tag rule.

Make sure that the values you provide are within the range of values advertised by storage capabilities of the vSAN
datastore.

7. On the **Storage compatibility** page, review the list of datastores under the **COMPATIBLE** and **INCOMPATIBLE** tabs

and click **Next** .
To be eligible, a datastore does not need to satisfy all the rule sets within the policy. The datastore must satisfy at
least one rule set and all rules within this set. Verify that the vSAN datastore meets the requirements set in the storage
policy and that it appears on the list of compatible datastores.

8. On the **Review and finish** page, review the policy settings, and click **Finish** .


The new policy is added to the list.

Assign this policy to a virtual machine and its virtual disks. vSAN places the virtual machine objects according to the
requirements specified in the policy. For information about applying the storage policies to virtual machine objects, see the
[vSphere Storage guide.](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/vsphere-storage.html)
### **Expanding and Managing a vSAN Cluster**

After you have set up your vSAN cluster, you can add ESXi hosts and capacity devices, remove ESXi hosts and devices,
and manage failure scenarios.


**Expanding a vSAN Cluster**

You can expand an existing vSAN cluster by adding ESXi hosts or adding devices to existing ESXi hosts, without
disrupting any ongoing operations.

Use one of the following methods to expand your vSAN cluster.

- Add new ESXi hosts to the cluster that are configured using the supported cache and capacity devices. See Add an
ESX Host to the vSAN Cluster.

- Move existing ESXi hosts to the vSAN cluster and configure them by using a host profile. See Configuring ESX Hosts
in the vSAN Cluster Using Host Profiles.

- Add new capacity devices to ESXi hosts that are cluster members. See Add Devices to the Disk Group in vSAN
Cluster.


**Expanding vSAN Cluster Capacity and Performance**


If your vSAN cluster is out of storage capacity or when you notice reduced performance, you can expand the vSAN cluster
for capacity and performance.

- For vSAN ESA, expand the storage capacity of your vSAN cluster by adding flash devices to the storage pools of the
existing ESXi hosts or by adding one or more new ESXi hosts with supported flash devices.

- For vSAN OSA, expand the storage capacity of your vSAN cluster either by adding storage devices to existing
disk groups or by adding disk groups. New disk groups require flash devices for the cache. For information about
adding devices to disk groups, see Add Devices to the Disk Group in vSAN Cluster. Adding capacity devices without
increasing the cache might reduce your cache-to-capacity ratio to an unsupported level. For hybrid configurations,


VMware by Broadcom 1717


VMware Cloud Foundation 9.0


which combine SSDs for caching and HDD for capacity, a 10% cache-to-capacity ratio is recommended. For all-flash
there is no fixed cache-to-capacity ratio.
Improve the vSAN cluster performance by adding at least one cache device (flash) and one capacity device (flash or
magnetic disk) to an existing storage I/O controller or to a new ESXi host. Or you can add one or more ESXi hosts with
disk groups to produce the same performance impact after vSAN completes automatic rebalance in the vSAN cluster.

Although compute-only ESXi hosts can exist in a vSAN cluster, and consume capacity from other ESXi hosts in
the vSAN cluster, add uniformly configured ESXi hosts for efficient operation. Although it is best to use the same or
similar devices in your disk groups or storage pools, any device listed on the _Broadcom Compatibility Guide_ [at https://](https://compatibilityguide.broadcom.com/)
[compatibilityguide.broadcom.com/ is supported. Try to distribute capacity evenly across ESXi hosts. For information about](https://compatibilityguide.broadcom.com/)
adding devices to disk groups or storage pools, see Create a Disk Group or Storage Pool in vSAN Cluster .

After you expand the vSAN cluster capacity, enable automatic rebalance to distribute resources evenly across the vSAN
cluster. For more information, see About vSAN Cluster Rebalancing.


**Use Quickstart to Add ESXi Hosts to a vSAN Cluster**


If you configured your vSAN cluster through Quickstart, you can use the Quickstart workflow to add ESXi hosts and
storage devices to the vSAN cluster.

- The Quickstart workflow must be available for your vSAN cluster.

- Verify that the resources, including drivers, firmware, and storage I/O controllers, are listed in the _Broadcom_
_Compatibility Guide_ [at https://compatibilityguide.broadcom.com/.](https://compatibilityguide.broadcom.com/)

- VMware recommends creating uniformly configured ESXi hosts in the vSAN cluster, so you have an even distribution
of components and objects across devices in the cluster. However, there might be situations where the vSAN cluster
becomes unevenly balanced, particularly during maintenance or if you overcommit the capacity of the vSAN datastore
with excessive virtual machine deployments.

- No network configuration performed through the Quickstart workflow has been modified from outside of the Quickstart
workflow.
Networking settings configured while creating the vSAN cluster with Quickstart have not been modified.

When you add new ESXi hosts to the vSAN cluster, you can use the Cluster configuration wizard to complete the ESXi
host configuration. For more information about Quickstart, see Using Quickstart to Configure and Expand a vSAN Cluster.

**Note:**

If you are running vCenter on an ESXi host, the ESXi host cannot be placed into maintenance mode as you add it to a
vSphere cluster using the Quickstart workflow. All other virtual machines on the ESXi host must be powered off.


VMware by Broadcom 1718


VMware Cloud Foundation 9.0



1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under **Configuration**, click **Quickstart** .

4. On the **Add hosts** card, click **Add** to open the Add hosts wizard.



a) On the **Add hosts** page, enter information for new hosts, or click Existing hosts and select from hosts listed in the



inventory.
b) On the **Host Summary** page, verify the host settings.
c) On the Import Image page, import an image from the ESXi host to set as the new image for the cluster. You can



either select an existing image or import an image from one of the ESXi hosts.
d) On the **Review** page, click **Finish** .



5. On the Configure Cluster card, click **Configure** to open the Cluster configuration wizard.

a) On the **Configure the distributed switches** page, enter networking settings for the new hosts.
b) (optional) On the **Claim disks** page, select disks on each new host. If you enable Auto clam at the cluster level for

vSAN ESA, all the compatible disks are automatically claimed.
c) (optional) On the **Create fault domains** page, move the new hosts into their corresponding fault domains.

For more information about fault domains, see Managing Fault Domains in vSAN Clusters.
d) On the **Ready to complete** page, verify the cluster settings, and click **Finish** .

Verify the vSAN Skyline Health status.

**Add an ESXi Host to the vSAN Cluster**


You can add ESXi hosts to a running vSAN cluster without disrupting any ongoing operations.

- Verify that the resources, including drivers, firmware, and storage I/O controllers, are listed in the _Broadcom_
_Compatibility Guide_ [at https://compatibilityguide.broadcom.com/.](https://compatibilityguide.broadcom.com/)

- VMware recommends creating uniformly configured ESXi hosts in the vSAN cluster, so you have an even distribution
of components and objects across devices in the cluster. However, there might be situations where the vSAN cluster
becomes unevenly balanced, particularly during maintenance or if you overcommit the capacity of the vSAN datastore
with excessive virtual machine deployments.

- Verify that you configured the ESXi hosts for the vSAN network.

The new ESXi host's resources become associated with the cluster.

1. In the vSphere Client, navigate to the cluster.

|Option|Description|
|---|---|
|**New hosts**<br>|1.<br>Enter the IP address or FQDN.<br>2.<br>Enter the username and password associated with the ESXi<br>host.<br><br>|
|**Existing hosts**|1.<br>Select ESXi hosts that you previously added to vCenter.|



3. Click **Next** .

4. View the summary information and click **Next** .

5. Import an image from the ESXi host to set as the new image for the cluster. You can either select an existing image or

import an image from one of the ESXi hosts.

6. Review the settings and click **Finish** .

The ESXi host enters maintenance mode before the ESXi host is added to the vSphere cluster.


VMware by Broadcom 1719


VMware Cloud Foundation 9.0


Verify the vSAN Skyline Health status.

Verify that the vSAN Disk Balance health check is green.

For more information about vSAN cluster configuration and fixing problems, see vSAN Cluster Configuration Issues.

**Configuring ESXi Hosts in the vSAN Cluster Using Host Profile**


When you have multiple ESXi hosts in the vSAN cluster, you can use a host profile of an existing vSAN host to configure
the ESXi hosts in the vSAN cluster.

- Verify that the ESXi host is in maintenance mode.

- Verify that the hardware components, drivers, firmware, and storage I/O controllers are listed in the _Broadcom_
_Compatibility Guide_ [at https://compatibilityguide.broadcom.com/.](https://compatibilityguide.broadcom.com/)

The host profile includes information about storage configuration, network configuration, and other characteristics of the
ESXi host. If you are planning to create a vSphere cluster with many ESXi hosts, use the host profile feature. Host profiles
enable you to add more than one ESXi host at a time to the vSAN cluster.


VMware by Broadcom 1720


VMware Cloud Foundation 9.0


1. Create an ESXi host profile.

a) Navigate to **Policies and Profiles**, then click **Host Profiles** in the vSphere Client.
b) Click the **Extract Host Profile** icon.
c) On the **Select the host** dialog, select the ESXi host you intend to use as the reference ESXi host and click **Next** .

The selected ESXi host must be an active host.
d) On the **Name and description** dialog, enter a name for the new profile and click **Finish** .
e) Review the summary information for the new host profile and click **Finish** .

2. Attach the ESXi host to the intended host profile.

a) From the Profile list in the Host Profiles view, select the host profile to be applied to the ESXi host.
b) Click the **Attach/Detach Hosts and clusters to a host profile** icon ( ).
c) Select the host from the expanded list and click **Attach** to attach the host to the profile.

The host is added to the Attached Entities list.
d) Click **Next** .
e) Click **Finish** to complete the attachment of the host to the profile.

3. Detach the referenced vSAN host from the host profile.

When a host profile is attached to a cluster, the host or hosts within that cluster are also attached to the host profile.
However, when the host profile is detached from the cluster, the association between the host or hosts in the cluster
and that of the host profile remains intact.
a) From the Profile List in the Host Profiles view, select the host profile to be detached from a host or cluster.
b) Click the **Attach/Detach Hosts and clusters to a host profile** icon ( ).
c) Select the host or cluster from the expanded list and click **Detach** .
d) Click **Detach All** to detach all the listed hosts and clusters from the profile.
e) Click **Next** .
f) Click **Finish** to complete the detachment of the host from the host profile.

4. Verify the compliance of the vSAN host to its attached host profile and determine if any configuration parameters on

the host are different from those specified in the host profile.
a) Navigate to a host profile.

The **Objects** tab lists all host profiles, the number of hosts attached to that host profile, and the summarized results
of the last compliance check.
b)
Click the **Check Host Profile Compliance** icon ( ).

To view specific details about which parameters differ between the host that failed compliance and the host profile,
click the **Monitor** tab and select the Compliance view. Expand the object hierarchy and select the non-compliant
host. The parameters that differ are displayed in the Compliance window, below the hierarchy.

If compliance fails, use the Remediate action to apply the host profile settings to the host. This action changes all
host profile-managed parameters to the values that are contained in the host profile attached to the host.
c) To view specific details about which parameters differ between the host that failed compliance and the host profile,

click the **Monitor** tab and select the Compliance view.
d) Expand the object hierarchy and select the failing host.

The parameters that differ are displayed in the Compliance window, below the hierarchy.


VMware by Broadcom 1721


VMware Cloud Foundation 9.0


5. Remediate the host to fix compliance errors.

a) Select the **Monitor** tab and click **Compliance** .
b) Right-click the host or hosts to remediate and select **All vCenter Actions**   - **Host Profiles**   - **Remediate** .

You can update or change the user input parameters for the host profiles policies by customizing the host.
c) Click **Next** .
d) Review the tasks that are necessary to remediate the host profile and click **Finish** .

The host is part of the vSAN cluster and its resources are accessible to the vSAN cluster. The host can also access all
existing vSAN storage I/O policies in the vSAN cluster.


**Sharing Remote vSAN Datastores**

Remote datastore sharing enables vSAN clusters to share their datastores with other clusters.

You can provision virtual machines running on your local cluster to use storage space on a remote datastore. When you
provision a new virtual machine, you can select a remote datastore that is mounted to the client cluster. You can assign
any compatible storage policy configured for the remote datastore.

Mounting a remote datastore is a cluster-wide configuration. When you mount a remote datastore to a vSAN cluster, it is
available to all hosts in the cluster.

When you prepare a vSphere cluster for mounting remote datastore, select any one of the following vSAN cluster types:

- **vSAN HCI** cluster provides compute resources and storage resources. It can share its datastore across data centers
and vCenter instances and mount datastores from other vSAN HCI clusters.

- **Compute Cluster** is a vSphere cluster that can mount a remote datastore from a vSAN storage cluster. These clusters
are hosts in a vSphere cluster that only complies with the _Broadcom Compatibility Guide_ for vSphere, but not for
vSAN.

- **vSAN storage cluster** (deployment model based on vSAN ESA) provides storage resources, but not compute
resources. Its datastore can be mounted by compute clusters or vSAN HCI clusters across data centers and vCenter
instances.

vSAN datastore sharing has the following design considerations:

- vSAN single site and vSAN stretched clusters can share datastores across clusters in the same data center, or
across clusters managed by remote vCenter instances, as long as the source and the remote vCenter instances are
accessible and they pass the prechecks.

- The client hosts that are not part of a cluster are not supported. You can configure a single host compute-only cluster,
however VMs running on this node are affected in the event of a host failure.

- A datastore on a vSAN storage cluster or a vSAN HCI server cluster can be shared across up to 10 client clusters.

- A client cluster can mount up to 5 remote datastores from one or more vSAN storage cluster or vSAN server clusters.

- A single datastore can be mounted by up to 128 vSAN hosts, including hosts in the local vSAN server cluster.

- All objects that make up a virtual machine must reside on the same datastore.

- For vSphere HA to work with vSAN datastore sharing, configure the following failure response for Datastore with APD
on the client cluster: Power off and restart virtual machines.

- Data-in-transit encryption between a client and a remote vSAN storage cluster or HCI cluster is not supported.

The following configurations are not supported with vSAN datastore sharing:

- Remote provisioning of iSCSI volumes, or CNS persistent volumes. You can provision iSCSI volumes on the local
vSAN datastore, but not on any remote vSAN datastore. For remote provisioning of CNS persistent volumes, see
[vSphere Functionality Supported by vSphere Container Storage Plug-in and Using vSphere Container Storage Plug-in](http://techdocs.broadcom.com/us/en/vmware-cis/vsphere/container-storage-plugin/3-0/getting-started-with-vmware-vsphere-container-storage-plug-in-3-0/vsphere-container-storage-plug-in-concepts/vsphere-functionality-supported-by-vsphere-container-storage-plug-in.html)
[for HCI Mesh Deployment in the](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/container-storage-plugin/3-0/getting-started-with-vmware-vsphere-container-storage-plug-in-3-0/using-vsphere-container-storage-plug-in/using-vsphere-container-storage-plug-in-for-hci-mesh-deployment.html) _vSphere Storage_ guide.


VMware by Broadcom 1722


VMware Cloud Foundation 9.0


- Air-gapped networks or clusters using multiple vSAN VMkernel ports

- Client cluster mounting datastores from different vSAN architectures. vSAN OSA and vSAN ESA are not compatible,
and cannot share datastores with each other. If a cluster has mounted a datastore that uses vSAN OSA, it cannot
mount a datastore that uses vSAN ESA.


**Disaggregated Storage with vSAN Storage Cluster**

vSAN storage cluster is a fully distributed, scalable, shared storage solution for vSphere clusters and vSAN clusters.
Storage resources are disaggregated from compute resources, so you can scale storage and compute resources
independently.

vSAN storage cluster uses vSAN ESA and high-density vSAN Ready Nodes for increased capacity and performance.

**Note:**

vSAN storage cluster can be deployed by purchasing VMware Cloud Foundation or by acquiring the advanced addon offer for VMware vSphere Foundation. Licensing for vSAN storage cluster is based on a per-TiB metric, which
corresponds to the total amount of raw storage capacity needed for the environments.

A vSAN storage cluster acts as a server cluster that only provides storage. You can mount its datastore to vSphere
clusters configured as compute clusters or vSAN HCI client clusters.


vSAN storage clusters have the following design considerations:

- Supported only on vSAN ESA running on vSAN Ready Nodes certified for vSAN storage clusters.

- Cannot be mounted to a vSAN OSA client cluster.

- Acts as a storage server only, not as a client. It is recommended not to run workload virtual machines on vSAN storage
clusters.

- Requires a minimum of four ESXi hosts, each hosts with a minimum of 20 TiB per host for space efficiency. Broadcom
recommends a minimum of six ESXi hosts. To optimize performance, use a uniform configuration of storage devices
across all hosts.

- Supports the use of 25 GbE network connections between ESXi hosts in the vSAN storage cluster, though Broadcom
recommends the use of 100 GbE connections. Supports the use of 10 GbE network connections from compute clients


VMware by Broadcom 1723


VMware Cloud Foundation 9.0


to the vSAN storage clusters, though Broadcom recommends the use of 25 GbE connections. For best performance,
enable support for jumbo frames (MTU = 9000) and ensure you have sufficient resources at the network spine. For
smaller vSAN storage cluster configurations, Broadcom support the use of 10 GbE network connections between ESXi
[hosts. For more information, see vSAN ESA ReadyNode Hardware Guidance.](https://partnerweb.vmware.com/comp_guide2/vsanesa_profile.php)

- Requires a latency below five milliseconds between the client and the server ESXi hosts.

- Enable **Auto-Policy management** (Configure > vSAN > Services > Storage > Edit) to ensure optimal levels of
resilience and space efficiency.

- Enable **Automatic rebalance** (Configure > vSAN > Services > Advanced Options > Edit) to ensure an evenly
balanced, distributed storage system.

**Note:**

You can configure vSAN storage cluster only during cluster creation. You cannot convert an existing vSAN HCI cluster to
a vSAN storage cluster, and you cannot convert a vSAN storage cluster to a vSAN HCI cluster. You must deactivate vSAN
and reconfigure the cluster to make the conversion.

|Compute cluster|A compute cluster is a vSphere cluster with a small vSAN element<br>that enables it to mount a remote datastore hosted on a vSAN<br>storage cluster. The ESXi hosts in a compute cluster do not<br>have local storage. You can monitor the capacity, health, and<br>performance of the remote datastore.<br>Note:<br>Compute cluster does not require vSAN Ready Nodes.<br>Compute clusters have the following design considerations:<br>• vSAN networking must be configured on ESXi hosts in the<br>compute cluster.<br>• No vSAN storage eligible devices can be present on ESXi<br>hosts in a compute cluster.<br>• No data management features can be configured on the<br>compute cluster.|
|---|---|
|vSAN storage cluster|A vSAN storage cluster can separate the external VM traffic<br>from the internal vSAN storage traffic by utilizing the dedicated<br>VMkernel ports for different traffic types. With the vSAN storage<br>cluster, you have the option to use Storage cluster client network.|



**Cross-Cluster Capacity Sharing**

vSAN storage clusters or vSAN HCI clusters can share their datastores with other vSAN HCI clusters or compute clusters.
A vSAN storage cluster can act as a server to provide data storage, while a vSAN HCI cluster or compute cluster can also
act as a client that consumes storage from a remote datastore.


VMware by Broadcom 1724


VMware Cloud Foundation 9.0


Use the Datastore Management view to monitor and manage remote datastores mounted on the local vSAN cluster.
Each client vSAN cluster or compute-only client cluster can mount remote datastores from server vSAN clusters. Each
compatible vSAN cluster also can act as a server, and allow other vSAN clusters to mount its local datastore.

Monitor views for capacity, performance, health, and placement of virtual objects show the status of remote objects and
datastores.


**Using Remote vCenter Instances as Datastore Sources**

vSAN HCI and vSAN storage clusters can share remote datastores across vCenter instances. You can add a remote
vCenter as a datastore source for clusters on the local vCenter. Client clusters on the local vCenter can mount datastores
that reside on the remote vCenter.

Use the Remote Datastore Management page in vCenter to manage remote datastore sources ( **Configure** - **vSAN**

- **> Remote Datastore Management** ). Click the tabs to access information about shared datastores across vCenter
instances, add vCenter instances as datastores sources, and mount datastores to local clusters.

|Datastore Sources|View and manage datastore sources residing in remote vCenter instances. You can add or remove remote<br>datastore sources for the local vCenter.|
|---|---|
|**Clusters**|View and manage clusters residing in the local vCenter. You can mount or unmount datastores from remote<br>vCenter instances to the selected client cluster on the local vCenter.|
|**Datastores**|View all datastores available under this vCenter.|



vCenter to vCenter datastore sharing has the following design considerations:

- Each vCenter can serve up to 10 client vCenter instances.

- Each client vCenter can add up to 5 remote vCenter datastore sources.

- When a virtual machine on a client cluster managed by one vCenter uses storage from a remote server cluster
managed by another vCenter, the storage policy on the client's vCenter takes precedence.


**View Remote vSAN Datastores**


Use the Datastore Management page to view remote datastores mounted to the local vSAN cluster, and client clusters
sharing the local datastore.


VMware by Broadcom 1725


VMware Cloud Foundation 9.0


1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Datastore Management** .


This view lists information about each datastore mounted to the local cluster.

- Server cluster that hosts the datastore

- vCenter of the server cluster (if applicable)

- Capacity usage of the datastore

- Free capacity available

- Number of virtual machines using the datastore (number of virtual machines using the compute resources of the local
cluster, but the storage resources of the server cluster)

- Client clusters that have mounted the datastore

You can mount or unmount remote datastores from this page.

**Mount Remote vSAN Datastore**


You can mount one or more datastores to a local vSAN HCI cluster, compute cluster, or the stretched compute cluster.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Datastore Management** .

4. Click **Mount Remote Datastore** to open the wizard.

5. (Optional) Select a remote vCenter as the datastore source.

6. Select a datastore.

7. (Optional) If the server cluster is a vSAN stretched cluster, configure Site Coupling to choose the optimal data path

between the server and the client cluster.
A vSAN stretched cluster might have an asymmetrical network, where links within each availability zone have higher
bandwidth and lower latency than links between availability zones. A symmetrical network has similar links within each
availability zone and across availability zones.

8. Check the datastore compatibility, and click **Finish** .


The remote datastore is mounted to the local vSAN cluster.

When you provision a virtual machine, you can select the remote datastore as the storage resource. Assign a storage
policy that is supported by the remote datastore.

**Unmount Remote vSAN Datastore**


You can unmount a remote datastore from a vSAN cluster.

If no virtual machines on the local cluster are using the remote vSAN datastore, you can unmount the datastore from your
local vSAN cluster.


VMware by Broadcom 1726


VMware Cloud Foundation 9.0


1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Datastore Management** .

4. Select a remote datastore, and click **Unmount** .

5. Click **Unmount** to confirm.


The selected datastore is unmounted from the local cluster.

**Monitor Datastore Sharing with vSphere Client**


You can use the vSphere Client to monitor the status of vSAN datastore sharing operations.

vSAN capacity monitor notifies you when remote datastores are mounted to the cluster. You can select the remote
datastore to view its capacity information **(Monitor > vSAN > Capacity** ). vSAN displays a banner informing you in case
there are existing clusters mounting the vSAN datastore from this cluster.

- The Virtual Objects view ( **Monitor** - **> vSAN** - **Virtual Objects** ) shows the virtual objects used by the remote cluster
VMs .

- The Physical disk placement view ( **VM** - **Monitor** - **Physical disk placement** ) for a VM located on a remote datastore
shows information about its remote location.

vSAN health ( **Monitor** - **vSAN** - **Skyline Health** - **Health Findings** - **All** - **Filter by Category** ) checks report on the
status of HCI functions.

- Data > vSAN Object health check shows accessibility information of remote objects.

- Network > Server cluster partition check reports about network partitions between hosts in the client cluster and the
server cluster.

- Network > Latency checks the latency between hosts in the client cluster and the server cluster.

vSAN cluster performance views include virtual machine performance charts that display the virtual machine level
performance of the client cluster from the perspective of the remote cluster. You can select a remote datastore to view the
performance.

You can run pro-active tests on remote datastores to verify virtual machine creation and network performance. The virtual
machine creation test creates a virtual machine on the remote datastore. The Network performance test checks the
network performance between all hosts in the client cluster and all hosts the server clusters. For more information, see
Proactive Tests on vSAN Cluster.


**Add Remote vCenter as Datastore Source**


You can add a remote vCenter as a remote datastore source for client clusters on the local vCenter.

1. In the vSphere Client, navigate to the cluster.

2. Select **Configure** .

3. Under **vSAN**, click **Datastore Management** .

4. On the **Datastore Sources** tab, click **Add Remote Datastore Source** to open the wizard.

5. Enter information to specify the remote vCenter.

6. Check the compatibility, review the configuration, and click **Finish** .


The remote vCenter is added as a datastore source. vSAN clusters on the local vCenter can mount remote datastores
that reside on the remote vCenter.


VMware by Broadcom 1727


VMware Cloud Foundation 9.0


**Working with Members of the vSAN Cluster in Maintenance Mode**

Before you shut down, reboot, or disconnect an ESXi host that is a member of a vSAN cluster, you must put the ESXi host
in maintenance mode.

When working with maintenance mode, consider the following guidelines:

- When you place an ESXi host in maintenance mode, you must select a data evacuation mode, such as **Ensure**
**accessibilityFull data migration** or **No data migration** . Ensure accessibility is the default option and moves data, if
necessary.

- When any member ESXi host of a vSAN cluster enters maintenance mode, the cluster capacity automatically reduces
as the member ESXi host no longer contributes storage to the vSAN cluster.

- A virtual machine's compute resources might not reside on the ESXi host that is being placed in maintenance mode,
and the storage resources for virtual machines might be located anywhere in the vSAN cluster.

- The **Ensure accessibility** mode is faster than the **Full data migration** mode because the **Ensure accessibility**
migrates only the components from the hosts that are essential for running the virtual machines. When in this mode,
if you encounter a failure, the availability of your virtual machine is affected. Selecting the **Ensure accessibility** mode
does not reprotect your data during failure and you might experience unexpected data loss.

- The Enhanced durability mode helps to store the incremental data writes in case an unexpected host failure occurs
within your cluster while a host is in the maintenance mode. The ESXi host can enter maintenance mode when the
objects in the cluster use failure to tolerate (FTT) of 1 and Ensure accessibility evacuation mode.

- When you select the **Full data migration** mode, your data is automatically reprotected against a failure, if the
resources are available and the **Failures to tolerate** set to 1 or more. When in this mode, all components from the
ESXi host are migrated and, depending on the amount of data you have on the ESXi host, the migration might take
longer. With **Full data migration** mode, your virtual machines can tolerate failures, even during planned maintenance.

- When working with a three-host cluster, you cannot place a server in maintenance mode with **Full data migration** .
Consider designing a vSAN cluster with four or more ESXi hosts for maximum availability.

Before you place an ESXi host in maintenance mode, you must verify the following:

- If you are using **Full data migration** mode, verify that the cluster has enough ESXi hosts and capacity available to
meet the **Failures to tolerate** policy requirements.

- Verify that enough flash capacity exists on the remaining ESXi hosts to handle any flash read cache reservations. To
analyze the current capacity use per ESXi host, and whether a single ESXi host failure might cause the cluster to run
out of space and impact the vSAN cluster capacity, cache reservation, and cluster components, use the data migration
pre-check tests. For more information, see Check the Data Migration Capabilities of an ESX Host in the vSAN Cluster.

- Verify that you have enough capacity devices in the remaining ESXi hosts to handle stripe width policy requirements, if
selected.

- Make sure that you have enough free capacity on the remaining ESXi hosts to handle the amount of data that must be
migrated from the ESXi host entering maintenance mode.

The Confirm Maintenance Mode dialog box provides information to guide your maintenance activities. You can view the
impact of each data evacuation option.

- Whether or not sufficient capacity is available to perform the operation.

- How much data will be moved.

- How many objects will become non-compliant.

- How many objects will become inaccessible.


VMware by Broadcom 1728


VMware Cloud Foundation 9.0


**Check the Data Migration Capabilities of an ESXi Host in the vSAN Cluster**


Use data migration pre-check to identify the impact of migration options when placing an ESXi host into maintenance
mode or removing it from the cluster.

Before you place an ESXi host into maintenance mode, run the data migration pre-check. The test results provide
information to help you determine the impact to cluster capacity, predicted health checks, and any objects that will go out
of compliance. If the operation will not succeed, pre-check provides information about what resources are needed.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Monitor** tab.

3. Under vSAN, click **Data Migration Pre-check** .

4. Select an ESXi host, a vSAN data migration option, and click **Pre-check** .

vSAN runs the data migration precheck tests.

5. View the test results.

The pre-check results show whether the ESXi host can safely enter maintenance mode.

  - The **Object state** tab displays objects that might have issues after the data migration.

  - The **Cluster Capacity** tab displays the impact of data migration on the vSAN cluster before and after you perform
the operation.

  - The **Predicted Health** tab displays the health checks that might be affected by the data migration.

If the pre-check indicates that you can place the ESXi host into maintenance mode, you can click **Enter Maintenance**
**Mode** to migrate the data and place the ESXi host into maintenance mode.

**Place a Member of vSAN Cluster in Maintenance Mode**


Before you shut down, reboot, or disconnect an ESXi host that is a member of a vSAN cluster, you must place the ESXi
host in maintenance mode.

Verify that your environment has the capabilities required for the option you select.

When you place an ESXi host in maintenance mode, you must select a data evacuation mode, such as **Ensure**
**accessibility**, **Full data migration**, or **No data migration** . When any member ESXi host of a vSAN cluster enters
maintenance mode, the cluster capacity is automatically reduced, because the member ESXi host no longer contributes
capacity to the cluster. This also results in the vCLS VMs getting powered off and unregistered.

**Note:**

The vSAN file service virtual machines (FSVM) running on an ESXi host are automatically powered off when an ESXi host
in the vSAN cluster enters maintenance mode.

Any vSAN iSCSI targets served by this ESXi host are transferred to other ESXi hosts in the vSphere cluster, and thus the
iSCSI initiator are redirected to the new target owner.

1. In the vSphere Client, navigate to the cluster.

2. Expand the cluster, right-click the ESXi host and select **Maintenance Mode > Enter Maintenance Mode** .

|Select a data evacuation mode and click OK. Option|Description|
|---|---|
|**Option**<br>|**Description**<br>|
|**Ensure accessibility**|This is the default option. When you power off or remove the<br>ESXi host from the cluster, vSAN migrates just enough data to<br>ensure every object is accessible after the ESXi host goes into<br>maintenance mode. Select this option if you want to take the<br>ESXi host out of the cluster temporarily, for example, to install|



VMware by Broadcom 1729


VMware Cloud Foundation 9.0

|Option|Description|
|---|---|
||upgrades, and plan to have the ESXi host back in the vSphere<br>cluster. This option is not appropriate if you want to remove the<br>ESXi host from the vSphere cluster permanently.<br>Typically, only partial data evacuation is required. However, the<br>virtual machine might no longer be fully compliant to a virtual<br>machine storage policy during evacuation. That means, it might<br>not have access to all its replicas. If a failure occurs while the<br>ESXi host is in maintenance mode and the**Failures to tolerate**<br>is set to 1, you might experience data loss in the cluster.<br>**Note:** This is the only evacuation mode available if you are<br>working with a three-host cluster or a vSAN cluster configured<br>with three fault domains.<br>|
|**Full data migration**|vSAN evacuates all data to other ESXi hosts in the vSphere<br>cluster and maintains the current object compliance state. Select<br>this option if you plan to migrate the ESXi host permanently.<br>When evacuating data from the last ESXi host in the vSphere<br>cluster, make sure that you migrate the virtual machines to<br>another datastore and then place the ESXi host in maintenance<br>mode.<br>This evacuation mode results in the largest amount of data<br>transfer and consumes the most time and resources. All the<br>components on the local storage of the selected ESXi host are<br>migrated elsewhere in the vSphere cluster. When the ESXi host<br>enters maintenance mode, all virtual machines have access<br>to their storage components and are still compliant with their<br>assigned storage policies.<br>**Note:**<br>If there are objects in reduced availability state, this mode<br>maintains this compliance state and does not guarantee that the<br>objects will become compliant.<br>If a virtual machine object that has data on the host is not<br>accessible and is not fully evacuated, the host cannot enter<br>maintenance mode.|



VMware by Broadcom 1730


VMware Cloud Foundation 9.0

|Option|Description|
|---|---|
|**No data migration**|vSAN does not evacuate any data from this ESXi host. If you<br>power off or remove the ESXi host from the vSphere cluster,<br>some virtual machines might become inaccessible.|



A vSphere cluster with three fault domains has the same restrictions that a three-host vSphere cluster has, such as the
inability to use **Full data migration** mode or to reprotect data after a failure.

Alternatively, you can place an ESXi host in the maintenance mode by using ESXCLI. Before placing an ESXi host in
this mode, ensure that you powered off the virtual machines that running on the ESXi host.

To perform an action before entering maintenance mode, run the following command on the ESXi host:
```
   esxcli system maintenanceMode set --enable 1 --vsanmode=<str>
```

Following are the string values allowed for vsanmode:

  - ensureObjectAccessibility - Evacuate data from the disk to ensure object accessibility in the vSAN cluster, before
entering maintenance mode.
**Note:** The default value is ensureObjectAccessibility. This value will be used if you do not specify any value for the
vsanmode.

  - evacuateAllData - Evacuate all data from the disk before entering maintenance mode.

  - noAction - Do not move vSAN data out of the disk before entering maintenance mode.

To verify the status of the ESXi host, run the following command:
```
   esxcli system maintenanceMode get
```

To exit maintenance mode, run the following command:
```
   esxcli system maintenanceMode set --enable 0
```

You can track the progress of data migration in the cluster.


**Managing Fault Domains in vSAN Clusters**

Fault domains enable you to protect against rack or chassis failure if your vSAN cluster spans across multiple racks or
blade server chassis.

You can create fault domains and add one or more hosts to each fault domain. A fault domain consists of one or more
vSAN hosts grouped according to their physical location in the data center. When configured, fault domains enable vSAN
to tolerate failures of entire physical racks as well as failures of a single host, capacity device, network link, or a network
switch dedicated to a fault domain.

The **Failures to tolerate** policy for the cluster depends on the number of failures a virtual machine is provisioned to
tolerate. When a virtual machine is configured with the **Failures to tolerate** set to 1 `(FTT=1)`, vSAN can tolerate a single
failure of any kind and of any component in a fault domain, including the failure of an entire rack.

When you configure fault domains on a rack and provision a new virtual machine, vSAN ensures that protection objects,
such as replicas and witnesses, are placed in different fault domains. For example, if a virtual machine's storage policy
has the **Failures to tolerate** set to N `(FTT=n)`, vSAN requires a minimum of `2*n+1` fault domains in the cluster. When
virtual machines are provisioned in a cluster with fault domains using this policy, the copies of the associated virtual
machine objects are stored across separate racks.

A minimum of three fault domains are required to support FTT=1. For best results, configure four or more fault domains in
the cluster. A cluster with three fault domains has the same restrictions that a three host cluster has, such as the inability
to reprotect data after a failure and the inability to use the **Full data migration** mode. For information about designing and
sizing fault domains, see Designing and Sizing vSAN Fault Domains.


VMware by Broadcom 1731


VMware Cloud Foundation 9.0


Consider a scenario where you have a vSAN cluster with 16 hosts. The hosts are spread across four racks, that is, four
hosts per rack. To tolerate an entire rack failure, create a fault domain for each rack. You can configure a cluster of such
capacity with the **Failures to tolerate** set to 1. If you want the **Failures to tolerate** set to 2, configure five fault domains in
the cluster.

When a rack fails, all resources including the CPU, memory in the rack become unavailable to the cluster. To reduce
the impact of a potential rack failure, configure fault domains of smaller sizes. Increasing the number of fault domains
increases the total amount of resource availability in the cluster after a rack failure.

When working with fault domains, follow these best practices.

- Configure a minimum of three fault domains in the vSAN cluster. For best results, configure four or more fault domains.

- A host not included in any fault domain is considered to reside in its own single-host fault domain.

- You do not need to assign every vSAN host to a fault domain. If you decide to use fault domains to protect the vSAN
environment, consider creating equal sized fault domains.

- When moved to another cluster, vSAN hosts retain their fault domain assignments.

- When designing a fault domain, place a uniform number of hosts in each fault domain.

- You can add any number of hosts to a fault domain. Each fault domain must contain at least one host.


**Create a New Fault Domain in vSAN Cluster**


To ensure that the virtual machine objects continue to run smoothly during a rack failure, you can group hosts in different
fault domains.

- Choose a unique fault domain name. vSAN does not support duplicate fault domain names in a cluster.

- Verify the version of your ESXi hosts.

- Verify that your vSAN hosts are online. You cannot assign hosts to a fault domain that is offline or unavailable due to
hardware configuration issue.

When you provision a virtual machine on the vSphere cluster with fault domains, vSAN distributes protection components,
such as witnesses and replicas of the virtual machine objects across different fault domains. As a result, the vSAN
environment becomes capable of tolerating entire rack failures in addition to a single host, storage disk, or network failure.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Fault Domains** .

4. Click the plus icon.

The New Fault Domain wizard opens.

5. Enter the fault domain name.

6. Select one or more hosts to add to the fault domain.

A fault domain cannot be empty. You must select at least one host to include in the fault domain.

7. Click **Create** .

The selected hosts appear in the fault domain. Each fault domain displays the used and reserved capacity information.
This enables you to view the capacity distribution across the fault domain.

**Move ESXi Host into Selected Fault Domain in vSAN Cluster**


You can move an ESXi host into a selected fault domain in the vSAN cluster.


VMware by Broadcom 1732


VMware Cloud Foundation 9.0


1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Fault Domains** .

4. Click and drag the ESXi host that you want to add onto an existing fault domain.

The **Add Hosts To Domain** dialog appears.

5. Click **Move** .

The selected ESXi host appears in the fault domain.

**Move ESXi Hosts out of a Fault Domain in vSAN Cluster**


Depending on your requirement, you can move ESXi hosts out of a fault domain.

Verify that the ESXi host is online. You cannot move ESXi hosts that are offline or unavailable from a fault domain.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Fault Domains** .

a) Click and drag the ESXi host from the fault domain to the Standalone Hosts area.
b) Click **Move** to confirm.


The selected ESXi host is no longer part of the fault domain. Any ESXi host that is not part of a fault domain is considered
to reside in its own single-host fault domain.

You can add ESXi hosts to fault domains. See Move ESX Host into Selected Fault Domain in vSAN Cluster.

**Rename a Fault Domain in vSAN Cluster**


You can change the name of an existing fault domain in your vSAN cluster.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Fault Domains** .

a) Click the Actions icon on the right side of the fault domain, and choose **Edit** .
b) Enter a new fault domain name.

4. Click **Apply** or **OK** .

The new name appears in the list of fault domains.

**Remove Selected Fault Domains from vSAN Cluster**


When you no longer need a fault domain, you can remove it from the vSAN cluster.


VMware by Broadcom 1733


VMware Cloud Foundation 9.0


1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Fault Domains** .

4. Click the Actions icon on the right side of the fault domain, and select **Delete** .

5. Click **Delete** to confirm.


All ESXi hosts in the fault domain are removed and the selected fault domain is deleted from the vSAN cluster. Each ESXi
host that is not part of a fault domain is considered to reside in its own single-host fault domain.

**Tolerate Additional Failures with Fault Domain in vSAN Cluster**


Fault domains in a vSAN cluster provides resilience and assures that the data is available even with failures based on
policy.

With failures to tolerate (FTT) set to 1, the object can tolerate a failure. However, a temporary failure followed by a
permanent failure in a cluster can result in data loss. An additional fault domain provides vSAN the ability to create a
durability component without having additional FTTs for the object. vSAN triggers this extra component during planned
and unplanned failures. Unplanned failures include network disconnect, disk failures, and host failures. Planned failures
include Entering Maintenance Mode (EMM). For example, a 6 host cluster with RAID 6 object cannot create a durability
component if there is a host failure.

vSAN ensures the data availability of the objects when the components go offline and comes back online unexpectedly
based on the FTTs specified in the storage policy. During a failure, the writes of the failed component is redirected to
the durability component. When the component recovers from the transient failure and comes back online, the durability
component disappears and results in the resynchronization of the component.

Without the durability component in place, if there is a second permanent failure in the cluster and the mirror object is
affected, the object data gets permanently lost even if the failure is resolved.


**Using vSAN Data Protection**

vSAN data protection powered by enables local virtual machine protection and remote virtual machine replication.

vSAN data protection supports vSAN ESA enabled HCI clusters and compute only clusters that mount a datastore
from a vSAN storage cluster. It allows you to quickly recover virtual machines from operational failures or ransomware
attacks, using native snapshots stored locally on the cluster. The replication of virtual machines enables you to protect
virtual machines by ensuring data back up, minimal data loss, and quick data recovery in case of a site failure. For more
[information, see the vSAN Data Protection guide.](https://techdocs.broadcom.com/bin/gethidpage?ux-context-string=vlrdp_105&appid=vlrdp-9-0-3&language=&format=rendered)


**Deploy and Configure the Appliance**


To enable vSAN replication, you must deploy the appliance in the vSphere Client.

After deploying, you must configure the appliance to connect to a vCenter instance on both the protected and the
[recovery sites. For more information on deploying and configuring appliance, see Deploy the VMware Live Recovery](https://techdocs.broadcom.com/bin/gethidpage?ux-context-string=srm_182&appid=vlr-9-0-3&language=en&format=rendered)
[Appliance and Configure the VMware Live Recovery Appliance to Connect to a vCenter instance.](https://techdocs.broadcom.com/bin/gethidpage?ux-context-string=srm_182&appid=vlr-9-0-3&language=en&format=rendered)


**Clustering Applications on vSAN**

vSAN supports two main clustering options such as shared VMDKs using SCSI-3 persistent reservations for Windows
Server Failover Cluster (WSFC) and multi-writer VMDKs for Oracle RAC.


VMware by Broadcom 1734


VMware Cloud Foundation 9.0


For example, applications such as Linux-based clustering solutions require shared disk access control, and can use
shared VMDKs with SCSI-3 persistent reservations. Solutions such as IBM Db2 pureScale or specific clustered file
systems can be configured to use multi-writer VMDKs for concurrent shared access.

WSFC ensures high availability for SQL Server Failover Cluster Instances (FCI). It requires shared storage with SCSI-3
persistent reservations to allow hosts safe shared disk access. vSAN support multiple WSFC deployment methods,
including native vSAN shared VMDKs and vSAN iSCSI.

Oracle RAC enables multiple Oracle instances to access a single datastore providing high availability and scalability.
vSAN aggregates the local disks of ESXi hosts into a shared datastore. The virtual disks that are configured in multi-writer
mode allow multiple VMs (RAC nodes) to access the same disk.


**vSAN Support for WSFC**


ESXi supports vSAN framework and up to five node WSFC clusters.

- Supports vSAN for Windows Server 2012 and later.

- WSFC on vSAN can work with any type of disk, "Thin" and "Thick"-provisioned disks.

- Enables customers to move away from using pRDM.

- WSFC on vSAN supports vSphere HA, DRS, and vMotion.
[For more information on the configuration, see Setup for Windows Server Failover Clustering on VMware vSphere.](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/setup-for-windows-server-failover-clustering.html)
**Important:**

The configuration steps for sharing disks are applicable to both data disks and quorum disks.


**vSAN Support for Oracle RAC**


ESXi supports vSAN framework and up to five node Oracle RAC 19c clusters.

- Supports vSAN for Oracle RAC 19c and later.

- Oracle RAC on vSAN can work with any type of disk, "Thin" and "Thick"-provisioned disks.

- Enables to move away from using pRDM.

- Oracle RAC on vSAN supports vSphere HA, DRS, and vMotion.


**Add Hard Disks to the First Virtual Machine of a WSFC or Oracle RAC Cluster Using vSAN Shared**
**VMDKs**


In a WSFC cluster, storage disks are shared between nodes. In an Oracle RAC cluster with vSAN shared VMDKs, you
must add shared disks to the first VM across physical hosts.

- [Use Hardware Version 13 or later. See Broadcom Hardware Compatibility Guide.](https://compatibilityguide.broadcom.com/)

- Prepare vSAN deployment.

1. In the vSphere Client, select the newly created virtual machine, right-click, and select **Edit Settings** .

2. From the **Add New Device** drop-down menu, select **SCSI Controller** .

3. Perform the following:

  - For WSFC, in New SCSI controller, select **VMware Paravirtual** as the Change Type and set SCSI Bus Sharing to
**Physical** .

  - For Oracle RAC, in New SCSI controller, select **VMware Paravirtual** as the Change Type and set SCSI Bus
Sharing to **None** .

From the **Sharing** drop-down list, select **Multi-writer** .


VMware by Broadcom 1735


VMware Cloud Foundation 9.0


4. From the **Add New Device** drop-down menu, select **Hard Disk** .

5. Expand the **New Hard disk** and select the required disk size.

6. In the Virtual Device Node, select **New SCSI controller** and **SCSI (1:0) New Hard disk** from the drop-down lists.

7. Click **OK** to create a new hard disk.

**Add Hard Disks to the Additional Virtual Machines of the WSFC or Oracle RAC Cluster Using vSAN**
**Shared VMDKs**


To allow shared access to disk resources, point to existing disks on the VM, the first node of a WSFC cluster or an Oracle
RAC cluster. Use the same SCSI IDs while assigning disks to all additional nodes.

- Obtain SCSI IDs for all virtual disks to be shared.

- Obtain disk file path on datastore for all shared disks.

1. In the vSphere Client, select the newly created virtual machine, right-click and select **Edit Settings** .

2. Click the **New device** drop-down menu, select **SCSI Controller** .

3. Perform one of the following:

  - For WSFC, in new SCSI Controller, select **VMware Paravirtual** and set **SCSI Bus Sharing** to Physical. Click **OK** .

  - For Oracle RAC, in New SCSI controller, select **VMware Paravirtual** as the Change Type and set SCSI Bus
Sharing to **None** .

From the **Sharing** drop-down list, select **Multi-writer** .

**Note:**

You must select same SCSI controller type, for example VMware Paravirtual, that you selected for the first virtual
machine’s shared storage disks.

4. Select the newly created virtual machine in step 1, right-click and select **Edit Settings** .

5. Click the **New device** drop-down menu, select **Existing Hard Disk** .

6. In **Disk File Path**, browse to the location of the disk to be shared specified for the first node.

7. Expand **New Hard disk** .

8. Select the same SCSI ID you chose for the first virtual machine’s shared storage disks, (for example, select **SCSI**

**(1:0)** ).

The disk SCSI ID for this virtual machine’s shared storage must match the corresponding SCSI ID for the first virtual
machine.

9. Click **OK** .

[For more information on HA and DRS, see Use WSFC in an vSphere HA and vSphere DRS Environment.](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/setup-for-windows-server-failover-clustering/use-wsfc-in-an-ha-drs-environment.html)


**Using the vSAN iSCSI Target Service**

Use the iSCSI target service to enable ESXi hosts and physical workloads that reside outside the vSAN cluster to access
the vSAN datastore.

This feature enables an iSCSI initiator on a remote ESXi host to transport block-level data to an iSCSI target on a storage
device in the vSAN cluster. vSAN support Windows Server Failover Clustering (WSFC), so WSFC nodes can access
[vSAN iSCSI targets. For more information, see Broadcom knowledge base article 313230.](https://knowledge.broadcom.com/external/article/313230)

After you configure the vSAN iSCSI target service, you can discover the vSAN iSCSI targets from a remote host. To
discover vSAN iSCSI targets, use the IP address of any host in the vSAN cluster, and the TCP port of the iSCSI target.


VMware by Broadcom 1736


VMware Cloud Foundation 9.0


To ensure high availability of the vSAN iSCSI target, configure multipath support for your iSCSI application. You can use
the IP addresses of two or more hosts to configure the multipath. vSAN iSCSI VIP is an IP address that you can use to
discovery IP address for initiators to discover vSAN iSCSI target service without having to provide the underlying host
vSAN iscsi vmkernel ip address details.

**Note:**

vSAN iSCSI target service does not support other vSphere or ESXi clients or initiators, third-party hypervisors, or
migrations using raw device mapping (RDMs).

vSAN iSCSI target service supports the following CHAP authentication methods:

**CHAP** In CHAP authentication, the target authenticates the initiator, but
the initiator does not authenticate the target.
**Mutual CHAP** In mutual CHAP authentication, an extra level of security enables
the initiator to authenticate the target.

[For more information about using the vSAN iSCSI target service, see iSCSI Target Usage Guide.](https://www.vmware.com/docs/vmw-vsan-iscsi-target-usage-guide)


**iSCSI Targets**

You can add one or more iSCSI targets that provide storage blocks as logical unit numbers (LUNs). vSAN identifies each
iSCSI target by a unique iSCSI qualified Name (IQN). You can use the IQN to present the iSCSI target to a remote iSCSI
initiator so that the initiator can access the LUN of the target.

Each iSCSI target contains one or more LUNs. You define the size of each LUN, assign a vSAN storage policy to each
LUN, and enable the iSCSI target service on a vSAN cluster. You can configure a storage policy to use as the default
policy for the home object of the vSAN iSCSI target service.


**iSCSI Initiator Groups**

You can define a group of iSCSI initiators that have access to a specified iSCSI target. The iSCSI initiator group restricts
access to only those initiators that are members of the group. If you do not define an iSCSI initiator or initiator group, then
each target is accessible to all iSCSI initiators.

A unique name identifies each iSCSI initiator group. You can add one or more iSCSI initiators as members of the group.
Use the IQN of the initiator as the member initiator name.


**Enable the vSAN iSCSI Target Service**


Before you can create iSCSI targets and LUNs and define iSCSI initiator groups, you must enable the iSCSI target service
on the vSAN cluster. You must create a VMkernel port on each host to use the vSAN iSCSI default network or select an
existing port.

Ensure that you have defined the default network for vSAN iSCSI target service.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN click **Services** .

4. On the vSAN iSCSI Target Service row, click **Enable** .

The Enable vSAN iSCSI Target Service wizard opens.


VMware by Broadcom 1737


VMware Cloud Foundation 9.0


5. In the Basic tab, you can select the default network, TCP port, and Authentication method at this time. You also can

select a vSAN storage policy.

6. In the Virtual IP tab, click the Enable vSAN iSCSI Virtual IP slider to turn it on.

7. Select the network device, IP address, subnet mask, and gateway. When you enable virtual IP, you can use this IP

for iSCSI connections. You can disable the virtual IP, as required. If you disable virtual IP, it might cause iSCSI traffic
interruptions.

**Note:**

vSAN stretched cluster does not support vSAN iSCSI virtual IP.

8. Click **Enable** .


The vSAN iSCSI target service is enabled.
After the iSCSI target service is enabled, you can create iSCSI targets and LUNs, and define iSCSI initiator groups.

**Create a vSAN iSCSI Target**


You can create or edit an iSCSI target and its associated LUN.

Verify that the vSAN iSCSI target service is enabled.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

a) Under vSAN, click **iSCSI Targets** .
b) Click the **iSCSI Targets** tab.

If you have not configured virtual IP, click **Configure virtual IP** to configure IP for all the initiators. For more
information, see Enable the vSAN iSCSI Target Service **.** You can use virtual IP to access the list of iSCSI targets. If
you have already configured virtual IP, you can view and copy the virtual IP address.
c) Click **Add** . The **New iSCSI Target** dialog box is displayed. If you leave the target IQN field blank, the IQN is

generated automatically.
d) Enter a target **Alias** .
e) Select a **Storage policy**, **Network**, **TCP port**, and **Authentication** method.

**Note:**

vSAN stretched clusters does not support vSAN iSCSI virtual IP.
f) Select the **I/O Owner Location** . This feature is available only if you have configured vSAN cluster as a stretched
cluster. It allows you to specify the site location for hosting the iSCSI target service for a target. This helps in
avoiding the cross site iSCSI traffic. If you have set the policy as Site disaster tolerance: Site mirroring - stretched
cluster, then in the event of a site failure, the I/O owner location changes to the alternate site. After the site
failure recovery, the I/O owner location automatically changes back to the original I/O owner location as per the
configuration. You can select one of the following options to set the site location:

    - **Either** : Hosts the iSCSI target service either on Preferred or Secondary site.

    - **Preferred** : Hosts the iSCSI target service on the Preferred site.

    - **Secondary** : Hosts the iSCSI target service on the Secondary site.

3. Click **Apply** .


iSCSI target is created and listed under the vSAN iSCSI Targets section with the information such as IQN, I/O owner host,
and so on. You can use the filter icon to filter the group name and initiator count.

Define a list of iSCSI initiators that can access this target.


VMware by Broadcom 1738


VMware Cloud Foundation 9.0


**Add a LUN to a vSAN iSCSI Target**


You can add one or more LUNs to a vSAN iSCSI target, or edit an existing LUN.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

a) Under vSAN, click **iSCSI Targets** .
b) Click the **iSCSI Targets** tab, and select a target.
c) In the vSAN iSCSI LUNs section, click **Add** . The **Add LUN to Target** dialog box is displayed.
d) Enter the size of the LUN. The vSAN Storage Policy configured for the iSCSI target service is assigned

automatically. You can assign a different policy to each LUN.

3. Click **Add** .

**Resize a LUN on a vSAN iSCSI Target**


Depending on your requirement, you can increase the size of an online LUN.

Online resizing of the LUN is enabled only if all hosts in the cluster are upgraded to vSAN 9.0 or later.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **iSCSI Targets** .

4. Click the **iSCSI Targets** tab and select a target.

5. In the vSAN iSCSI LUNs section, select a LUN and click **Edit** . The Edit LUN dialog box is displayed.

6. Increase the size of the LUN depending on your requirement.

7. Click **OK** .

**Place a LUN in Offline Mode**


You can place a LUN on a vSAN iSCSI target in offline mode.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **iSCSI Targets** .

4. Click the **iSCSI Targets** tab and select a target.

5. In the vSAN iSCSI LUNs section, select a LUN and click **Offline** . The Place iSCSI LUN offline dialog box is displayed.

6. Click **Yes** .

**Remove a LUN from a vSAN iSCSI Target**


You can delete a LUN from a vSAN iSCSI target.


VMware by Broadcom 1739


VMware Cloud Foundation 9.0


1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **iSCSI Targets** .

4. Click the **iSCSI Targets** tab and select a target.

5. In the vSAN iSCSI LUNs section, select a LUN and click **Remove** . The Remove iSCSI LUNs from Target dialog box is

displayed.

6. Click **Remove** .

**Create a vSAN iSCSI Initiator Group**


You can create a vSAN iSCSI initiator group to provide access control for vSAN iSCSI targets.

Only iSCSI initiators that are members of the initiator group can access the vSAN iSCSI targets.

**Note:** The initiators outside the initiator group cannot access the target if the initiator group for access control is created
on the iSCSI target. The existing connections from these initiators will be lost and cannot be recovered until they are
added to the initiator group. You must check the current initiator connections and ensure that all the authorized initiators
are added to the initiator group before group creation.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

a) Under vSAN, click **iSCSI Targets** .
b) Click the **Initiator Groups** tab, and click **Add** . The **New Initiator Group** dialog box is displayed.
c) Enter a name for the iSCSI initiator group.
d) (Optional) To add members to the initiator group, enter the IQN of each member. Use the following format to enter

the member IQN:
```
   iqn.YYYY-MM.domain:name
```

Where:

    - YYYY = year, such as 2016

    - MM = month, such as 09

    - domain = domain where the initiator resides

    - name = member name (optional)

3. Click **Create** .

Add members to the iSCSI initiator group.

**Add Initiator to a vSAN iSCSI Initiator Group**


You can add a member to the vSAN iSCSI initiator group.


VMware by Broadcom 1740


VMware Cloud Foundation 9.0


1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

a) Under vSAN, click **iSCSI Targets** .
b) Click the **Initiator Groups** tab.
c) In the Accessible Targets section, click **Add** . The **Add Initiators** dialog box is displayed.
d) Enter an initiator name in the **Member initiator name** field.
e) Click **Add** to add a member to the initiator group.

3. Click **Add** .

The vSAN iSCSI initiator is created and listed.

**Assign a Target to a vSAN iSCSI Initiator Group**


You can assign a vSAN iSCSI target to an iSCSI initiator group.

Verify that you have an existing iSCSI initiator group.

Only those initiators that are members of the initiator group can access the assigned targets.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

a) Under vSAN, click **iSCSI Targets** .
b) Select the **Initiator Groups** tab.
c) In the Initiators section, click **Add** . The **Add Initiators** dialog box is displayed.
d) Select a target from the list of available targets.

3. Click **Add** .

**Monitor vSAN iSCSI Target Service**


You can monitor the iSCSI target service to view the physical placement of iSCSI target components and to check for
failed components.

Verify that you have enabled the vSAN iSCSI target service and created targets and LUNs.

You also can monitor the health status of the iSCSI target service.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Monitor** tab.

3. Under vSAN click **Virtual Objects** . The iSCSI targets are listed on the page.

4. Select a target and click **View Placement Details** . The Physical Placement shows where the data components of the

target are located, the LUNs associated with the target, and its physical location.

5. Click **Group components by host placement** to view the hosts associated with the iSCSI data components.

You can view the vSAN iSCSI target performance. For more information, see View vSAN Host Performance.

**Turn Off the vSAN iSCSI Target Service**


You can turn off the vSAN iSCSI target service.


VMware by Broadcom 1741


VMware Cloud Foundation 9.0


Workloads running on iSCSI LUNs are stopped when you turn off the iSCSI target service. Before you turn it off, ensure
that there are no workloads running on iSCSI LUNs.

Turning off vSAN iSCSI target service does not delete the LUNs/Targets. If you wish to reclaim the space, delete the
LUNs/targets manually before you turn off vSAN iSCSI target service. For more information, see Remove a LUN from a
vSAN iSCSI Target.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Services** .

4. On the vSAN **iSCSI Target Service** row, click **EDIT** .

The Edit vSAN iSCSI Target Service wizard opens.

5. Click the **Enable vSAN iSCSI Target Service** slider to turn it off and click **Apply** .


The vSAN iSCSI target service is not enabled.


**vSAN File Service**

Use the vSAN file service to create file shares in the vSAN datastore that client workstations or virtual machines can
access.

The data stored in a file share can be accessed from any device that has access rights. vSAN file service is a layer
that sits on top of vSAN to provide file shares. It currently supports SMB, NFSv3, and NFSv4.1 file shares. vSAN
file service comprises of vSAN Distributed File System (vDFS) which provides the underlying scalable filesystem by
aggregating vSAN objects, a Storage Services Platform which provides resilient file server end points and a control plane
for deployment, management, and monitoring. File shares are integrated into the existing vSAN Storage Policy Based
Management, and on a per-share basis. vSAN file service brings in capability to host the file shares directly on the vSAN
cluster.


VMware by Broadcom 1742


VMware Cloud Foundation 9.0


When you configure vSAN file service, vSAN creates a single VDFS distributed file system for the cluster which will be
used internally for management purposes. A file service VM (FSVM) is placed on each host. The FSVMs manage file
shares in the vSAN datastore. Each FSVM contains a file server that provides both NFS and SMB service.

A static IP address pool should be provided as an input while enabling file service workflow. One of the IP addresses is
designated as the primary IP address. The primary IP address can be used for accessing all the shares in the file services
cluster with the help of SMB and NFSv4.1 referrals. A file server is started for every IP address provided in the IP pool.
A file share is exported by only one file server. However, the file shares are evenly distributed across all the file servers.
To provide computing resources that help manage access requests, the number of IP addresses must be equal to the
number of hosts in the vSAN cluster.

vSAN file service supports vSAN stretched clusters and two-node vSAN clusters. A two-node vSAN cluster should have
two data node servers in the same location or office, and the witness in a remote or shared location.

For more information about Cloud Native Storage (CNS) file volumes, see the VMware vSphere Kubernetes Service
Components documentation.


**Limitations and Considerations of vSAN File Service**


Consider the following when configuring vSAN file service:

- vSAN supports two-node configurations and stretched clusters.

- vSAN supports 64 file servers in a 64 host setup.

- vSAN OSA cluster supports 100 file shares.

- vSAN supports file service on ESA.


VMware by Broadcom 1743


VMware Cloud Foundation 9.0




- vSAN ESA cluster supports 500 file shares. Out of those 500 file shares, maximum 100 file shares can be SMB. For
example, if you create 100 SMB file shares then the cluster can only support additional 400 NFS file shares.

- vSAN file service can connect only to a single network or port group.

- vSAN file services does not support the following:

 - Read-Only Domain Controllers (RODC) for joining domains because the RODC cannot create computer accounts.



As a security best practice, a dedicated org unit should be pre-created in the Active Directory and the user name
mentioned here should be controlling this organization.

- Disjoint namespace. When the primary DNS suffix of a server within an Active Directory domain does not match the



DNS name of the domain itself, it is referred to as disjoint namespace.

 - Multiple domains and Single Active Directory Forest environments.

- When a host enters maintenance mode, the file server moves to another FSVM. The FSVM on the host that entered
maintenance mode is powered off. After the host exits maintenance mode, the FSVM is powered on.



**Enable vSAN File Service**


You can enable vSAN file services on a vSAN OSA cluster or a vSAN ESA cluster.

Ensure that the following are configured before enabling the vSAN file services:




- The vSAN cluster must be a regular vSAN cluster, a vSAN stretched cluster, or a vSAN ROBO cluster.

- Every ESXi host in the vSAN cluster must have minimal hardware requirements such as:

 - Minimum 16 Core CPU

 - Minimum 128 GbE physical memory

 - Minimum 10 GbE network

- You must ensure to prepare the network as vSAN file service network:

 - If using standard switch based network, the Promiscuous Mode and Forged Transmits are enabled as part of the



vSAN file services enablement process.

- If using vSphere Distributed Switch (DVS) based network, vSAN file services are supported on vSphere Distributed



Switch (DVS). Create a dedicated distributed port group for vSAN file services in the DVS. MacLearning and Forged
Transmits are enabled as part of the vSAN file services enablement process for a provided DVS port group.

- **Important:**



If using NSX-based network, ensure that MacLearning is enabled for the provided network entity from the NSX
admin console, and all the hosts and File Services nodes are connected to the desired NSX network. For more
information, see Create an NSX MAC Discovery Segment Profile.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN click **Services** .

4. On the File Service row, click **Enable** .

The Enable File Service wizard opens.

5. From the **Select** drop-down, select a network.

6. In the File service agent, select one of the following options to download the OVF file.

|Option|Description|
|---|---|
|Automatically load latest OVF|This option lets the system search and download the OVF.<br>**Note:**|



VMware by Broadcom 1744


VMware Cloud Foundation 9.0

|Option|Description|
|---|---|
||~~•~~<br>Ensure that you have configured the proxy and firewall so that<br>vCenter can access the following website and download the<br>appropriate JSON file.<br>For more information about configuring the vCenter DNS, IP<br>address, and proxy settings, see thevCenter Configuration guide.<br>•<br>**Use current OVF**: Allows you to use the OVF that is already<br>available.<br>•<br>**Automatically load latest OVF**: Allows the system to search<br>and download the latest OVF.|
|Manually load OVF|This option allows you to browse and select an OVF that is<br>already available on your local system.<br>**Note:** If you select this option, you should upload all the following<br>files:<br>•<br>`VMware-vSAN-File-Services-Appliance-x.x.x`<br>`.x-x_OVF10.mf`<br>•<br>`VMware-vSAN-File-Services-Appliance-x.x.x`<br>`.x-x-x_OVF10.cert`<br>•<br>`VMware-vSAN-File-Services-Appliance-x.x.x`<br>`.x-x-x-system.vmdk`<br>•<br>VMware-vSAN-File-Services-Appliance-x.x.x.x-x-cloud-compo<br>nents.vmdk<br>•<br>VMware-vSAN-File-Services-Appliance-x.x.x.x-x-log.vmdk<br>•<br>VMware-vSAN-File-Services-Appliance-x.x.x.x-x_OVF10.ovf|



7. Click **Enable** .


- The OVF is downloaded and deployed.

- The vSAN file services is enabled.

- A file services VM (FSVM) is placed on each host.

**Note:** The FSVMs are managed by the vSAN file services. Do not perform any operation on the FSVMs.

**Configure vSAN File Service**


You can configure the file service, which enable you to create file shares on your vSAN datastore.

Ensure the following before configuring the vSAN file service:




- Enable vSAN file service.

- Allocate static IP addresses as file server IPs from vSAN file service network, each IP is the single point access to
vSAN file shares.

 - For best performance, the number of IP addresses must be equal to the number of hosts in the vSAN cluster.

 - All the static IP addresses must be from the same subnet.

 - Every static IP address has a corresponding FQDN, which must be part of the Forward lookup and Reverse lookup



zones in the DNS server.

- If you are planning to create a Kerberos based SMB file share or a Kerberos based NFS file share, you need the
following:

 - Microsoft Active Directory (AD) domain to provide authentication to create an SMB file share or an NFS file share



with the Kerberos security.

- (Optional) Active Directory Organizational Unit to create all file server computer accounts.

- A domain user in the directory service with the sufficient privileges to create and delete computer accounts.



VMware by Broadcom 1745


VMware Cloud Foundation 9.0


1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Services** .

4. On the File Service row, click **Configure Domain** .

The File Service Domain wizard opens.

5. In the File Service Domain page, enter the unique namespace and click **Next** . The domain name must have minimum

two characters. The first character must be an alphabet or a number. The remaining characters can include an
alphabet, a number, an underscore ( _ ), a period ( . ), a hyphen ( - ).

6. In the Networking page, enter the following information, and click **Next** :

  - **Protocol** : You can select IPv4 or IPv6. vSAN file service only supports IPv4 or IPv6 stack. The reconfiguration
between IPv4 and IPv6 is not supported.

  - **DNS servers** : Enter a valid DNS server to ensure the proper configuration of file service.

  - **DNS suffixes** : Provide the DNS suffix that is used with the file service. All other DNS suffixes from where the
clients can access these file servers must also be included. File service does not support DNS domain with
single label, such as "app", "wiz", "com" and so on. A domain name given to file service must be of the format
[thisdomain.registerdrootdnsname. DNS name and suffix must adhere to the best practices detailed in https://](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/selecting-the-forest-root-domain)
[docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/selecting-the-forest-root-domain.](https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/selecting-the-forest-root-domain)

  - **Subnet mask** : Enter a valid subnet mask. This text box appears when you select IPv4.

  - **Prefix length** : Enter a number between 1 and 128. This text box appears when you select IPv6.

  - **Gateway** : Enter a valid gateway.

  - **IP Pool** : Enter IP addresses and the corresponding DNS names.

vSAN ESA cluster supports 500 file shares. Out of those 500 file shares, maximum 100 file shares can be SMB. For
example, if you create 100 SMB file shares then the cluster can only support additional 400 NFS file shares.

Each file server on a vSAN ESA cluster can support a maximum of 50 file shares and requires at least 10 IPs to have
the maximum of 500 shares. With the increase in the file servers or file shares per host, there might be an impact on
the performance of vSAN file service. For best performance, the number of IP address must to be equal to the number
of hosts in the vSAN cluster.

Affinity site option is available if you are configuring vSAN file service on a vSAN stretched cluster. This option allows
you to configure the placement of the file server on **Preferred** or **Secondary** site. This helps in reducing the cross-site
traffic latency. The default value is **Either**, which indicates that no site affinity rule is applied to the file server.

**Note:** If your cluster is a ROBO cluster, ensure that the Affinity site value is set to **Either** .

In a site failure event, the file server affiliated to that site fails over to the other site. The file server fails back to the
affiliated site when it is recovered. Configure more file servers to one site if more workloads can be expected from a
certain site.

**Note:** If the file server contains SMB file shares, then it does not failback automatically even if the site failure is
recovered.

Consider the following while configuring the IP addresses and DNS names:

  - To ensure proper configuration of file service, the IP addresses you enter in the Networking page must be static
addresses and the DNS server must have records for those IP addresses. For best performance, the number of IP
addresses must be equal to the number of hosts in the vSAN cluster.

  - You can have a maximum of 64 hosts in the cluster. If large scale cluster support is configured, you can enter up to
64 IP addresses.

  - You can use the following options to automatically fill the IP address and DNS server name text boxes:


VMware by Broadcom 1746


VMware Cloud Foundation 9.0


**AUTO FILL** : This option is displayed after you enter the first IP address in the IP address text box. Click the AUTO
FILL option to automatically fill the remaining fields with sequential IP addresses, based on the subnet mask and
gateway address of the IP address that you have provided in the first row. You can edit the auto filled IP addresses.
**LOOK UP DNS** : This option is displayed after you enter the first IP address in the IP address text box. Click the
LOOK UP DNS option to automatically retrieve the FQDN corresponding to the IP addresses in the IP address
column.

**Note:**

    - [All valid rules apply for the FQDNs. For more information, see https://tools.ietf.org/html/rfc953.](https://datatracker.ietf.org/doc/html/rfc953)

    - The first part of the FQDN, also known as NetBIOS Name, must not have more than 15 characters.

The FQDNs are automatically retrieved only under the following conditions:

   - You must have entered a valid DNS server in the Domain page.

   - The IP addresses entered in the IP Pool page must be static addresses and the DNS server must have records

for those IP addresses.

7. In the Directory service page, enter the following information and click **Next** .

|Option|Description|
|---|---|
|**Directory service**|Configure an Active Directory domain to vSAN file service for<br>authentication. If you are planning to create an SMB file share or<br>an NFSv4.1 file share with Kerberos authentication, then you must<br>configure an AD domain to vSAN file service.|
|**AD domain**|Fully qualified domain name joined by the file server.|
|**Preferred AD Server**|Enter the IP address of the preferred AD server. In case of multiple<br>IP addresses, ensure that they are separated by comma.|
|**Organizational unit (Optional)**|Contains the computer account that the vSAN file service<br>creates. In an organization with complex hierarchies, create the<br>computer account in a specified container by using a forward<br>slash mark to denote hierarchies (for example, organizational_unit/<br>inner_organizational_unit).<br>**Note:** By default, the vSAN file service creates the computer<br>account in the Computers container.|
|**AD username**|User name to be used for connecting and configuring the Active<br>Directory service.<br>This user name authenticates the active directory on the domain.<br>A domain user authenticates the domain controller and creates<br>vSAN file service computer accounts, related SPN entries, and<br>DNS entries (when using Microsoft DNS). As a best practice,<br>create a dedicated service account for the file service.<br>A domain user in the directory service with the following sufficient<br>privileges to create and delete computer account:<br>•<br>(Optional) Add/Update DNS entries|



VMware by Broadcom 1747


VMware Cloud Foundation 9.0

|Option|Description|
|---|---|
|**Password**|Password for the user name of the Active Directory on the domain.<br>vSAN file service use the password to authenticate to AD and to<br>create the vSAN file service computer account.|



**Note:**

  - vSAN file service does not support the following:

   - Read-Only Domain Controllers (RODC) for joining domains because the RODC cannot create computer

accounts. As a security best practice, a dedicated org unit must be pre-created in the Active Directory and the
user name mentioned here must be controlling this organization.

   - Disjoint namespace.

   - Multiple domains and Single Active Directory Forest environments.

  - Only English characters are supported for Active Directory user name.

  - Only single AD domain configuration is supported. However, the file servers can be put on a valid DNS
subdomain. For example, an AD domain with the name `example.com` can have file server FQDN as
`name1.eng.example.com` .

  - Pre-created computer accounts for file servers are not supported. Make sure that the user provided here have
sufficient privilege over the organizational unit.

  - vSAN file service also has a Health Check to indicate if the forward and reverse lookups for file servers are working
properly.

8. Review the settings and click **Finish** .


The file service domain is configured. File servers are started with the IP addresses that were assigned during the vSAN
file service configuration process.

Run vSAN health check and verify the health findings.

**Edit vSAN File Service**


You can edit and reconfigure the settings of a vSAN file service.

- If there are active shares, changing the Active Directory domain is not permitted as this action can disrupt the user
permissions on the active shares.

- If your Active Directory password has been changed, then you can edit the Active Directory configuration settings and
provide the new password.
**Note:** This action might cause minor disruption to the inflight I/Os on the file shares.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Services** .

4. On the File Service row, click **Edit** - **Edit domain** .

The File Service Domain wizard opens.

5. In the File Service Domain page, edit the file service domain name and click **Next** .

6. In the Networking page, make the appropriate configuration changes and click **Next** . You can edit the primary IP

addresses, static IP addresses, and DNS names. You can add or remove the primary IP addresses or static IP
addresses. You cannot change the DNS name without changing the IP.

**Note:** Changing domain information is a disruptive action. It might require all clients to use new URLs to reconnect to
the file shares.


VMware by Broadcom 1748


VMware Cloud Foundation 9.0


7. In the Directory service page, make appropriate directory related changes if required, and click **Next** .

**Note:** You cannot change the AD domain, organizational unit, and username after initially configuring vSAN file
services.

8. In the Review page, click **Finish** after making necessary changes.


The changes are applied to the vSAN file service configuration.

**Disable vSAN File Service**


You can disable vSAN file service.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Services** .

4. On the File Service row, click **Edit** - **Disable** .

The Disable File Service wizard opens.

5. Click **Disable** .

  - If you disable file service with existing file shares, the file service domain will not be deleted. File shares remain
stored in the vSAN datastore, and their configuration is preserved for future use.

  - If you disable file service without existing file shares, the empty file service domains without any active file shares
gets automatically cleaned up. This ensures that your vSAN environment remains free of unused or orphaned
domains, with optimized system performance and resource usage.

**Create a vSAN File Share**


When the vSAN file service is enabled, you can create one or more file shares on the vSAN datastore.

- If you are creating an SMB file share or a NFSv4.1 file share with Kerberos security, then ensure that you have
configured vSAN file service to an Active Directory domain.

- Ensure that you have set `Host.Config.Storage` privilege.

**Considerations for Share Name and Usage**

- Usernames with non-ascii characters can be used to access share data.

- Share names cannot exceed 80 characters and can contain English characters, numbers, and hyphen character.
Every hyphen character must be preceded and followed by a number or alphabet. Consecutive hyphens are not
allowed.

- For SMB type shares, file and directories can contain any Unicode compatible strings.

- [For pure NFSv4 type shares, the file and directories can contain any UTF-8 compatible strings. See Network File](https://datatracker.ietf.org/doc/html/rfc7530)
[System (NFS) Version 4 Protocol.](https://datatracker.ietf.org/doc/html/rfc7530)

- For pure NFSv3 and NFSv3+NFSv4 shares file and directories can contain only ASCII compatible strings.

- Migrating any share data from older NFSv3 to new vSAN file service shares with NFSv4 only requires conversion of all
file and directories names to UTF-8 encoding. There are third part tools to achieve the same.

vSAN file service does not support using NFS file shares on ESXi .


VMware by Broadcom 1749


VMware Cloud Foundation 9.0


1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **File Shares** .

vSAN ESA cluster supports 500 file shares. Out of those 500 file shares, maximum 100 file shares can be SMB. For
example, if you create 100 SMB file shares then the cluster can only support additional 400 NFS file shares.

Each file server on a vSAN ESA cluster can support a maximum of 50 file shares and requires at least 10 IPs to have
the maximum of 500 shares. With the increase in the file servers or file shares per host, there might be an impact
on the performance of vSAN file service. For best performance, the number of IP addresses must to be equal to the
number of hosts in the vSAN cluster.

4. Click **Add** .

The Create file share wizard opens.

5. In the General page, enter the following information and click **Next** .

  - **Name** : Enter a name for the file share.

  - **Protocol** : Select an appropriate protocol. vSAN file service supports SMB and NFS file system protocols.
If you select the **SMB** protocol, you can also configure the SMB file share to accept only the encrypted data using
the **Protocol encryption** or Access based enumeration option. The access based enumeration displays only the
files and folders that you have permissions to access. The files or folders are hidden if you do not have the Read
(or equivalent) permissions. You can enable both protocol encryption and access based enumeration in a vSAN
cluster.
If you select the **NFS** protocol, you can configure the file share to support either **NFS 3**, **NFS 4**, or both **NFS 3 and**
**NFS 4** versions. If you select **NFS 4** version, you can set either **AUTH_SYS** or **Kerberos** security.

**Note:**

SMB protocol and Kerberos security for NFS protocol can be configured only if the vSAN file service is configured
with Active Directory. For more information, see Configure vSAN File Service.

  - With SMB protocol, you can hide the files and folders that the share client user does not have permission to access
using the **Access based enumeration** option.

  - **Storage Policy** : Select an appropriate storage policy.

  - **Affinity site** : This option is available if you are creating a file share on a vSAN stretched cluster. This option helps
you place the file share on a file server that belongs to the site of your choice. Use this option when you prefer low
latency while accessing the file share. The default value is **Either**, which indicates that the file share is placed on a
site with less traffic on either preferred or secondary site.

  - **Storage space quotas** : You can set the following values:

   - **Share warning threshold** : When the share reaches this threshold, a warning message is displayed.

   - **Share hard quota** : When the share reaches this threshold, new block allocation is denied.

  - **Labels** : A label is a key-value pair that helps you organize file shares. You can attach labels to each file share and
then filter them based on their labels. A label key is a string with 1~250 characters. A label value is a string and the
length of the label value should be less than 1k characters. vSAN file service supports up to 5 labels per share.

6. The Net access control page, provides options to define access to the file share. Net access control options are

available only for NFS shares. Select one of the following options and click **Next** .

  - **No access** : Select this option to make the file share inaccessible from any IP address.

  - **Allow access from any IP** : Select this option to make the file share accessible from all IP addresses.

  - **Customize net access** : Select this option to define permissions for specific IP addresses. Using this option you
can specify whether a particular IP address can access, make changes, or only read the file share. You can also
enable **Root squash** for each IP address. Root squash protects the NFS server from unauthorized root-level client
access. You can enter the IP addresses in the following formats:


VMware by Broadcom 1750


VMware Cloud Foundation 9.0


- A single IP address. For example, 123.23.23.123

- CIDR (Classless Inter-Domain Routing) notation by using a slash followed by a number, indicating how many

bits of the IP address are dedicated to the network portion.

- A range by specifying a starting IP address and ending IP address separated by a hyphen ( - ). For example,

123.23.23.123-123.23.23.128

- Asterisk ( * ) to imply all the clients.



7. In the Review page, review the settings, and then click **Finish** .

A new file share is created on the vSAN datastore.

**View vSAN File Shares**


You can view the list of vSAN file shares.

The vSAN ESA cluster displays the number of existing file shares and the maximum file share limit allowed in a cluster.

1. In the vSphere Client, navigate to the cluster.
2. Click the **Configure** tab.
3. Under vSAN, click **File Shares** .


A list of vSAN file shares appears. For each file share, you can view information such as storage policy, hard quota, usage
over quota, actual usage, and so on.

**Access vSAN File Shares**


You can access a file share from a host client.


**Access NFS File Share**
You can access a file share from a host client, using an operating system that communicates with NFS file systems.
For RHEL-based Linux distributions, NFS 4.1 support is available in RHEL 7.3 and CentOS 7.3-1611 running kernel
3.10.0-514 or later. For Debian based Linux distributions, NFS 4.1 support is available in Linux kernel version 4.0.0 or
later. All NFS clients must have unique hostnames for NFSv4.1 to work. You can use the Linux mount command with the
Primary IP to mount a vSAN file share to the client. For example: `mount -t nfs4 -o minorversion=1,sec=sys`
`<primary ip>:/vsanfs/<share name>` . NFSv3 support is available for RHEL-based and Debian based Linux
distributions. You can use the Linux mount command to mount a vSAN file share to the client. For example: mount `-t`
`nfs vers=3 <nfsv3_access_point> <localmount_point>` .

Sample v41 commands for verifying the NFS file share from a host client:
```
   [root@localhost ~]# mount -t nfs4 -o minorversion=1,sec=sys <primary ip address>:/vsan
   fs/TestShare-0 /mnt/TestShare-0
   [root@localhost ~]# cd /mnt/TestShare-0/
   [root@localhost TestShare-0]# mkdir bar
   [root@localhost TestShare-0]# touch foo
   [root@localhost TestShare-0]# ls -l
   total 0
   drwxr-xr-x. 1 root root 0 Feb 19 18:35 bar
   -rw-r--r--. 1 root root 0 Feb 19 18:35 foo
```

**Access NFS Kerberos File Share**
A Linux client accessing an NFS Kerberos share should have a valid Kerberos ticket.

**Sample NFSv4 commands for verifying the NFS Kerberos file share from a host client:**

An NFS Kerberos share can be mounted using the following mount command:


VMware by Broadcom 1751


VMware Cloud Foundation 9.0

```
   [root@localhost ~]# mount -t nfs4 -o minorversion=1,sec=krb5/krb5i/krb5p <primary ip ad
   dress>:/vsanfs/TestShare-0 /mnt/TestShare-0
   [root@localhost ~]# cd /mnt/TestShare-0/
   [root@localhost TestShare-0]# mkdir bar
   [root@localhost TestShare-0]# touch foo
   [root@localhost TestShare-0]# ls -l
   total 0
   drwxr-xr-x. 1 root root 0 Feb 19 18:35 bar
   -rw-r--r--. 1 root root 0 Feb 19 18:35 foo
```

**Changing Ownership of a NFS Kerberos share**

You must log in using the AD domain user name for changing the ownership of a share. The AD domain user
name provided in the file service configuration acts as a sudo user for the Kerberos file share.
```
   [root@localhost ~]# mount -t nfs4 -o minorversion=1,sec=sys <primary ip address>:/vsan
   fs/TestShare-0 /mnt/TestShare-0
   [fsadmin@localhost ~]# chown user1 /mnt/TestShare-0
   [user1@localhost ~]# ls -l /mnt/TestShare-0
   total 0
   drwxr-xr-x. 1 user1 domain users 0 Feb 19 18:35 bar
   -rw-r--r--. 1 user1 domain users 0 Feb 19 18:35 foo

```

**Access SMB File Share**
You can access an SMB file share from a Windows client.

Ensure that the Windows client is joined to the Active Directory domain that is configured with vSAN file service.

1. Copy the SMB file share path using the following procedure:



1. In the vSphere Client, navigate to the cluster.
2. Click the **Configure** tab.
3. Under vSAN, click **File Service Shares** .



List of all the vSAN file shares appears.
4. Select the SMB file share that you want to access from the Windows client.
5. Click **COPY PATH** - **SMB** .



The SMB file share path gets copied to your clipboard.



2. Log into the Windows client as a normal Active Directory domain user.

3. Access the SMB file share using path that you have copied. For example: \\vsan-file-server-dns-name\namespace

\share-name.

**Edit a vSAN File Share**


You can edit the settings of a vSAN file share.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **File Service Shares** .

List of all the vSAN file shares appears.


VMware by Broadcom 1752


VMware Cloud Foundation 9.0


4. Select the file share that you want to modify and click **Edit** .

5. In the Edit file share page, make appropriate changes to the file share settings and click **Finish** .


The file share settings are updated.

**Note:** vSAN does not allow file share protocol change between SMB and NFS.

**Manage SMB File Share on vSAN Cluster**


vSAN file service supports the shared folders snap-in for the Microsoft Management Console (MMC) for managing the
SMB shares on the vSAN cluster.

You can perform the following tasks on vSAN file system SMB shares using the MMC tool:

- Manage Access Control List (ACL).

- Close open files.

- View active sessions.

- View open files.

- Close client connections.

1. Copy the MMC Command using the following procedure:



1. In the vSphere Client, navigate to the cluster.



Click the **Configure** tab.
Under vSAN, click **File Service Shares** .
List of all the vSAN file shares appears.
2. Select the SMB file share that you want to manage from the Windows client using the MMC tool.
3. Click **COPY MMC COMMAND** .



The MMC command gets copied to your clipboard. For example: fsmgmt.msc /computer:\\vsan-file-service-dnsname.



2. Log into the Windows client as a file service admin user. The file service admin user is configured when you create the

file service domain. A file service admin user has all the privileges on the file server.

3. In the search box on the taskbar, type Run, and then select **Run** .

4. In the Run box, run the MMC command that you have copied to access and manage the SMB share using the MMC

tool.

**Delete a vSAN File Share**


You can delete a file share when you no longer need it.

When you delete a file share, all the snapshots associated with that file share are also deleted.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **File Service Shares** .

List of all the vSAN file shares appears.

4. Select the file share that you want to modify and click **Delete** .

5. On the Delete file shares dialogue, click **Delete** .

The data gets deleted.


VMware by Broadcom 1753


VMware Cloud Foundation 9.0


**vSAN Distributed File System Snapshot**


A snapshot provides a space-efficient and time-based archive of the data.

It provides the ability to retrieve data from a file or a set of files in the event of accidental deletion of a file. A file system
level snapshot provides you information about the files that have been changed and the changes made to the file. It
provides you an automated file recovery service and it is more efficient compared to the traditional tape-based backup
method. A snapshot on its own does not provide a full disaster recovery solution but it can be used by the third-party
backup vendors to copy the changed files (incremental backup) to a different physical location.

vSAN file services has a built-in feature that allows you to create a point- in-time image of the vSAN file share. When the
vSAN file service is enabled, you can create up to 32 snapshots per share. A vSAN file share snapshot is a file system
snapshot that provides a point-in-time image of a vSAN file share.


**Considerations for File System Snapshot**

- Use Default as the snapshot name to retrieve data.

- Snapshot name cannot exceed 100 characters and can contain English characters, numbers, and special characters
except the following:

 - " (ASCII 34)

 - $ (ASCII 36)

 - % (ASCII 37)

 - & (ASCII 38)

 -  - (ASCII 42)

 - / (ASCII 47)

 - : (ASCII 58)

 - < (ASCII 60)

 -  - (ASCII 62)

 - ? (ASCII 63)

 - \ (ASCII 92)

 - ^ (ASCII 94)

 - | (ASCII 124)

 - ~ (ASCII 126)


**Create a Snapshot**
When the vSAN file service is enabled, you can create one or more snapshots that provide a point-in-time image of the
vSAN file share. You can create a maximum of 32 snapshots per file share.

You should have created a vSAN file share.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **File Service Shares** .

A list of vSAN file shares appears.

4. Select the file share for which you want to create a snapshot and then click **Snapshots** - **New Snapshot** .

Create new snapshot dialogue appears.

5. On the Create new snapshot dialogue, provide a name for the snapshot, and click **Create** .


A point-in-time snapshot for the selected file share is created.


VMware by Broadcom 1754


VMware Cloud Foundation 9.0


**View a Snapshot**
You can view the list of snapshots along with the information such as date and time of the snapshot creation, and its size.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **File Service Shares** .

A list of vSAN file shares appears.

4. Select a file share and click **Snapshots** .


A list of snapshots for that file share appears. You can view information such as date and time of the snapshot creation,
and its size.

**Delete a Snapshot**
You can delete a snapshot when you no longer need it.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **File Service Shares** .

A list of vSAN file shares appears.

4. Select a file share and click **Snapshots** .

A list of snapshots of that belongs to the file share you have selected appears.

5. Select the snapshot that you want to delete and click **Delete** .

You cannot delete the last snapshot available.

**Rebalance Workload on vSAN File Service Hosts**


Skyline Health displays the workload balance health status for all the hosts that are part of the vSAN file service
Infrastructure.

If there is an imbalance in the workload of a host, you can correct it by rebalancing the workload.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Monitor** tab.

3. Under vSAN, click **Skyline Health** .

4. Under Skyline Health, expand **File Service** and then click **Infrastructure Health** .

The Infrastructure Health tab displays a list of all the hosts that are part of the vSAN file service infrastructure. For
each host, the status of workload balance is displayed. If there is an imbalance in the workload of a host, an alert is
displayed in the **Workload Balance** column.

5. Click **Remidiate Imbalance** and then **Rebalance** to fix the imbalance.

Before proceeding with rebalancing, consider the following:

  - During rebalancing, containers in the hosts with an imbalanced workload might be moved to other hosts. The
rebalancing activity might also impact the other hosts in the cluster.

  - During the rebalance process, the workloads running on NFS shares are not disrupted. However, the I/O to SMB
shares located in the containers that have moved are disrupted.


The host workload is balanced and the workload balance status turns green.


VMware by Broadcom 1755


VMware Cloud Foundation 9.0


**Monitor Performance of vSAN File Service**


You can monitor the performance of NFS and SMB file shares.

Ensure that vSAN Performance Service is enabled. If you are using the vSAN Performance Service for the first time, you
see a message alerting you to enable it. For more information about vSAN Performance Service, see Monitoring vSAN
Performance.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Monitor** tab.

3. Under vSAN, click **Performance** .

|Click the File Share tab. Select one of the following options: Option|Action|
|---|---|
|**Option**<br>|**Action**<br>|
|**File share**<br>|Select the file share for which you want to generate and view the<br>performance report.<br><br>|
|**Time Range**|~~•~~<br>Select**Last** to select the number of hours for which you want<br>to view the performance report.<br>•<br>Select**Custom** to select the date and time for which you<br>want to view the performance report.<br>•<br>Select**Save** to add the current setting as an option to the<br>Time Range list.|



6. Click **Show Results** .


The throughput, IOPS, and latency metrics of the vSAN file service for the selected period are displayed.

[For more information on vSAN Performance Graphs, see the Broadcom knowledge base article 214493.](https://knowledge.broadcom.com/external/article?legacyId=2144493)

**Monitor vSAN File Share Capacity**


You can monitor the capacity for both native file shares and CNS-managed file shares.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Monitor** tab.

3. Under vSAN, click **Capacity** .

4. Click **Capacity Usage** tab.

5. In the Usage breakdown section, expand **User data** - **File Shares** .


The file share capacity information is displayed.
For more information about monitoring vSAN capacity, see Monitor vSAN Capacity.

**Monitor vSAN File Service and File Share Health**


You can monitor the health of both vSAN file service and file share objects.

**View vSAN File Service Health**
You can monitor the vSAN file service health.

Ensure that vSAN Performance Service is enabled.


VMware by Broadcom 1756


VMware Cloud Foundation 9.0


1. In the vSphere Client, navigate to the cluster.

2. Click the **Monitor** tab.

3. Under vSAN, click **Skyline Health** .

4. In the Skyline Health section, expand **File Service** .

5. Click the following file service health parameters to view the status.

|Option|Action|
|---|---|
|**Infrastructure health**<br>|Displays the file service infrastructure health status per ESXi<br>host. For more information, click the**Info** tab.<br>|
|**File Server Health**<br>|Displays the file server health status. For more information, click<br>the**Info** tab.<br>|
|**Share health**|Displays the file service share health. For more information, click<br>the**Info** tab.|



**Monitor vSAN File Share Objects Health**
You can monitor the health of file share objects.

To view the file share object health, navigate to the vSAN cluster and then click **Monitor** - **vSAN** - **Virtual Objects** .

The device information such as name, identifier or UUID, number of devices used for each virtual machine, and how they
are mirrored across hosts is displayed in **View Placement Details** .


**Migrate a Hybrid vSAN Cluster to an All-Flash Cluster**

You can migrate the disk groups in a hybrid vSAN cluster to all-flash disk groups. This is applicable only for vSAN OSA
all-flash architecture.

- Ensure that all the vSAN policies that the cluster uses specify **No preference** for encryption services, space efficiency,
and storage tier.

- You must use RAID-1 (Mirroring) for **Failures to tolerate** until all the disk groups are converted to all-flash.

The vSAN hybrid cluster uses magnetic disks for the capacity layer and flash devices for the cache layer. You can change
the configuration of the disk groups in the cluster so that it uses flash devices on the cache layer and the capacity layer.

**Note:** Follow the steps to migrate a hybrid vSAN cluster to Solid State Drive (SSD), hybrid vSAN cluster to NVMe, or
SSD to NVMe.

1. Remove the hybrid disk groups on the host.

a) In the vSphere Client, navigate to the cluster.
b) Click the **Configure** tab.
c) Under vSAN, click **Disk Management** .
d) Under Disk Groups, select the disk group to remove, click **…**, and then click **Remove** .

Select **Full data migration** as a migration mode and click **Yes** .

**Note:** Migrate the disk groups on each host in the vSAN cluster.

2. Remove the physical HDD disks from the host.

3. Add the flash devices to the host.

Verify that no partitions exist on the flash devices.


VMware by Broadcom 1757


VMware Cloud Foundation 9.0


4. Create the all-flash disk groups on the host.

5. Repeat the steps 1 through 4 on each host until all the hybrid disk groups are converted to the all-flash disk groups.

**Note:**

If you cannot hot-plug disks on the host, place the host in maintenance mode before removing disks in the vSphere
Client. Shut down the host to replace the disks with flash devices. Then power on the host, exit maintenance mode,
and create new disk groups.


**Shutting Down and Restarting the vSAN Cluster**

You can shut down the entire vSAN cluster to perform maintenance or troubleshooting.

Use the Shutdown Cluster wizard to shutdown the vSAN cluster. The wizard performs the necessary steps and alerts you
when it requires user action. You also can manually shut down the cluster, if necessary.

**Note:** When you shut down a vSAN stretched cluster, the witness host remains active.


**Shut Down the vSAN Cluster Using the Shutdown Cluster Wizard**


Use the Shutdown cluster wizard to gracefully shut down the vSAN cluster for maintenance or troubleshooting.

Ensure vSAN client clusters have unmounted any vSAN datastores or vSAN storage clusters that have been shared.

The Shutdown Cluster Wizard is available with vSAN 9.0 and later releases.


VMware by Broadcom 1758


VMware Cloud Foundation 9.0



1. Prepare the vSAN cluster for shutdown.



a) Check the vSAN Skyline Health to confirm that the cluster is healthy.
b) Power off all virtual machines stored in the vSAN cluster, except for vCenter virtual machines and file service virtual

machines. If vCenter is hosted on the vSAN cluster, do not power off the vCenter virtual machine or virtual machine
service virtual machines (such as DNS, Active Directory) used by vCenter.
c) If this is an vSAN HCI Datastore Sharing server cluster, power off all client virtual machines stored on the cluster. If

the client cluster's vCenter virtual machine is stored on this cluster, either migrate or power off the virtual machine.
Once this server cluster is shutdown, its shared datastore is inaccessible to clients.
d) Verify that all resynchronization tasks are complete.



Click the **Monitor** tab and select **vSAN**     - **Resyncing Objects** .

**Note:**

If any member ESXi hosts are in lockdown mode, add the host's root account to the security profile Exception User list.
[For more information, see the vSphere Security guide.](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/vsphere-security.html)

2. Right-click the vSAN cluster in the vSphere Client, and select menu **Shutdown cluster** .

You also can click **Shutdown Cluster** on the vSAN Services page.

3. On the Shutdown cluster wizard, verify that the Shutdown pre-checks are green checks. Resolve any issues that are

red exclamations. Click **Next** .

If vCenter appliance is deployed on the vSAN cluster, the Shutdown cluster wizard displays the vCenter notice. Note
the IP address of the orchestration host, in case you need it during the cluster restart. If vCenter uses service virtual
machines such as DNS or Active Directory, note them as exceptional virtual machines in the Shutdown cluster wizard.

4. Select a reason for performing the shutdown, and click **Shutdown** .

The vSAN Services page changes to display information about the shutdown process.

5. Monitor the shutdown process.

vSAN performs the steps to shutdown the cluster, powers off the system virtual machines, and powers off the ESXi
hosts.

Restart the vSAN cluster. See Restart the vSAN Cluster.

**Restart the vSAN Cluster**


You can restart a vSAN cluster that is shut down for maintenance or troubleshooting.

Ensure that the ESXi hosts are in maintenance mode.

1. Power on the cluster ESXi hosts.

If the vCenter is hosted on the vSAN cluster, wait for vCenter to restart.

2. Right-click the vSAN cluster in the vSphere Client, and select menu **Restart cluster** .

You also can click **Restart Cluster** on the vSAN Services page.

3. On the Restart Cluster dialog, click **Restart** .

The vSAN Services page changes to display information about the restart process.


VMware by Broadcom 1759


VMware Cloud Foundation 9.0


4. After the cluster has restarted, check the vSAN Skyline Health and resolve any outstanding issues.

**Manually Shut Down and Restart the vSAN Cluster**


You can manually shut down the entire vSAN cluster to perform maintenance or troubleshooting.

Use the Shutdown Cluster wizard unless your workflow requires a manual shut down. When you manually shut down the
vSAN cluster, do not deactivate vSAN on the cluster.


VMware by Broadcom 1760


VMware Cloud Foundation 9.0



1. Shut down the vSAN cluster.



a) Check the vSAN Skyline Health to confirm that the cluster is healthy.
b) Power off all VMs running in the vSAN cluster, if vCenter is not hosted on the cluster. If vCenter is hosted in the



vSAN cluster, do not power off the vCenter VM or service VMs (such as DNS, Active Directory) used by vCenter.
c) If vSAN file service is enabled in the vSAN cluster, you must deactivate the file service. Deactivating the vSAN file



service removes an empty file service domain. If you want to retain the empty file service domain after restarting
the vSAN cluster, you must create an NFS or SMB file share before deactivating the vSAN file service.
d) Click the **Configure** tab and turn off HA. As a result, the cluster does not register host shutdowns as failures.



For vSphere 9.0 and later, enable vCLS retreat mode is deprecated. For more information, see the Broadcom
[knowledge base article 316514.](https://knowledge.broadcom.com/external/article/316514)
e) Verify that all resynchronization tasks are complete.

Click the **Monitor** tab and select **vSAN**     - **Resyncing Objects** .
f) If vCenter is hosted on the vSAN cluster, power off the vCenter virtual machine.

Make a note of the host that runs the vCenter VM. It is the host where you must restart the vCenter VM.
g) Deactivate cluster member updates from vCenter by running the following command on the ESXi hosts in the

cluster. Ensure that you run the following command on all the ESXi hosts.
```
     esxcfg-advcfg -s 1 /VSAN/IgnoreClusterMemberListUpdates
```

h) Log in to any host in the cluster other than the witness host.
i) Run the following command only on that host. If you run the command on multiple ESXi hosts concurrently, it may
cause a race condition causing unexpected results.
```
     python /usr/lib/vmware/vsan/bin/reboot_helper.py prepare
```

The command returns and prints the following:
```
   Cluster preparation is done.
```

**Note:**

    - The cluster is fully partitioned after the successful completion of the command.

    - If you encounter an error, resolve the issue based on the error message and try enabling vCLS retreat mode
again.

    - If there are unhealthy or disconnected ESXi hosts in the cluster, remove the ESXi hosts and retry the command.
j) Place all the ESXi hosts into maintenance mode with **No Action** . If the vCenter is powered off, use the following
command to place the ESXi hosts into maintenance mode with **No Action** .
```
     esxcli system maintenanceMode set -e true -m noAction
```

Perform this step on all the hosts.

To avoid the risk of data unavailability while using **No Action** at the same time on multiple hosts, followed by a
[reboot of multiple hosts, see the Broadcom knowledge base article 60424. To perform simultaneous reboot of all](https://knowledge.broadcom.com/external/article?legacyId=60424)
[hosts in the cluster using a built-in tool, see the Broadcom knowledge base article 70650.](https://knowledge.broadcom.com/external/article?legacyId=70650)
k) After all ESXi hosts have successfully entered maintenance mode, perform any necessary maintenance tasks and

power off the ESXi hosts.

2. Restart the vSAN cluster.

a) Power on the ESXi hosts.

Power on the physical box where ESXi is installed. The ESXi host starts, locates the VMs, and functions normally.

If any ESXi hosts fail to restart, you must manually recover the ESXihosts or move the bad hosts out of the vSAN
cluster.


VMware by Broadcom 1761


VMware Cloud Foundation 9.0


b) When all the ESXi hosts are back after powering on, exit all ESXi hosts from maintenance mode. If the vCenter is

powered off, use the following command on the ESXi hosts to exit maintenance mode.
```
   esxcli system maintenanceMode set -e false
```

Perform this step on all the ESXi hosts.
c) Log in to one of the ESXi hosts in the cluster other than the witness ESXi host.
d) Run the following command only on that ESXi host. If you run the command on multiple ESXi hosts concurrently, it

may cause a race condition causing unexpected results.
```
   python /usr/lib/vmware/vsan/bin/reboot_helper.py recover
```

The command returns and prints the following:
```
  Cluster reboot/power-on is completed successfully!
```

e) Verify that all the ESXi hosts are available in the cluster by running the following command on each ESXi host.
```
   esxcli vsan cluster get
```

f) Enable cluster member updates from vCenter by running the following command on the ESXi hosts in the cluster.
Ensure that you run the following command on all the ESXi hosts.


```
esxcfg-advcfg -s 0 /VSAN/IgnoreClusterMemberListUpdates

```


g) Restart the vCenter virtual machine if it is powered off. Wait for the vCenter virtual machine to be powered up and



[running. To deactivate vCLS retreat mode, see the Broadcom knowledge base article 80472.](https://knowledge.broadcom.com/external/article?legacyId=80472)
h) Verify again that all the ESXi hosts are participating in the vSAN cluster by running the following command on each



ESXi host.


```
   esxcli vsan cluster get
```

i) Restart the remaining VMs through vCenter.
j) Check the vSAN Skyline Health and resolve any outstanding issues.
k) (Optional) Enable vSAN file service.
l) (Optional) If the vSAN cluster has vSphere Availability enabled, you must manually restart vSphere Availability to
avoid the following error: `Cannot find vSphere HA master agent` .
To manually restart vSphere Availability, select the vSAN cluster and navigate to:



1. **Configure**    - **Services**    - **vSphere Availability**    - **EDIT**    - **Disable vSphere HA**
2. **Configure**    - **Services**    - **vSphere Availability**    - **EDIT**    - **Enable vSphere HA**

3. If there are unhealthy or disconnected ESXi hosts in the cluster, recover or remove the ESXi hosts from the vSAN

cluster. If vCenter uses service VMs such as DNS or Active Directory, note them as exceptional VMs in the Shutdown
cluster wizard.

Retry the above commands only after the vSAN Skyline Health shows all available ESXi hosts in the green state.

If you have a three-node vSAN cluster, the command `reboot_helper.py recover` cannot work in a one ESXi host
failure situation. As an administrator, do the following:

1. Temporarily remove the failure ESXi host information from the unicast agent list.
2. Add the ESXi host after running the following command.
```
     reboot_helper.py recover
```

Following are the commands to remove and add the ESXi host to a vSAN cluster:
```
   #esxcli vsan cluster unicastagent remove -a <IP Address> -t node -u <NodeUuid>
   #esxcli vsan cluster unicastagent add -t node -u <NodeUuid> -U true -a <IP Address> -p 12321
```

Restart the vSAN cluster. See Restart the vSAN Cluster.


VMware by Broadcom 1762


VMware Cloud Foundation 9.0

### **Device Management in a vSAN Cluster**

You can perform various device management tasks in a vSAN cluster.

You can create hybrid or all-flash disk groups, enable vSAN to claim devices for capacity and cache, turn LED indicators
on or off, mark devices as flash, mark remote devices as local, and so on.

**Note:** Marking devices as flash and marking remote devices as local are not supported in a vSAN ESA cluster.


**Managing Storage Devices in vSAN Cluster**

When you configure vSAN on a cluster, claim storage devices on each host to create the vSAN datastore.

The vSAN cluster initially contains a single vSAN datastore. As you claim disks for disk groups or storage pool on each
host, the size of the datastore increases according to the amount of physical capacity added by those devices.

vSAN has a uniform workflow for claiming disks across all scenarios. You can list all available disks by model and size, or
by host.

**Add a Storage Pool (vSAN ESA)** Each ESXi host that contributes storage contains a single storage
pool of flash devices. Each flash device provides caching and
capacity to the cluster. You can add a storage pool using any
compatible devices. vSAN creates only one storage pool per
host, irrespective of the number of storage disks the ESXi host is
attached to.

**Add a Disk Group (vSAN OSA)** When you add a disk group, you must specify the ESXi host and
the devices to claim. Each disk group contains one flash cache
device and one or more capacity devices. You can create multiple
disk groups on each ESXi host, and claim a cache device for each
disk group.

When adding a disk group, consider the ratio of flash cache to
consumed capacity. The ratio depends on the requirements and
workload of the cluster. For a hybrid cluster, consider using at least
10 percent of flash cache to consumed capacity ratio (not including
replicas such as mirrors).

**Note:**

If a new ESXi host is added to the vSAN cluster, the local
storage from that ESXi host is not added to the vSAN datastore
automatically. You must add a disk group to use the storage from
the new ESXi host.


**Claim Disks for vSAN Direct** Use vSAN Direct to enable stateful services to access raw,
non-vSAN local storage through a direct path.

You can claim host-local devices for vSAN Direct, and use vSAN
to manage and monitor those devices. On each local device,
vSAN Direct creates and independent VMFS datastore and makes
it available to your stateful application.

Each local vSAN Direct datastore appears as a vSAN-D datastore.

**Note:** If vSAN ESA is enabled for the cluster, you cannot claim
disks for vSAN Direct.


**Create a Disk Group or Storage Pool in vSAN Cluster**


Depending on the storage architecture you use in your cluster, you can decide to create a disk group or storage pool.


VMware by Broadcom 1763


VMware Cloud Foundation 9.0


**Create a Storage Pool on a Host (vSAN ESA)**
You can claim disks to define a storage pool on a vSAN host. Each host that contributes storage contains a single storage
pool of flash devices. Each flash device provides caching and capacity to the cluster. You can create a storage pool with
any devices that are compatible for ESA. vSAN creates only one storage pool per host. vSAN ESA uses a single tier
storage architecture where all devices contribute to capacity.

Use vSAN Managed Disk Claim to automatically claim all compatible disks on the cluster hosts. When you add new hosts,
vSAN will also claim compatible disks on those hosts. Any disks added manually are not affected by this setting. You can
manually add such disks to the storage pool.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Disk Management** .

4. Click **Claim Unused Disks** .

You can change the disk claim mode to use **vSAN Managed Disk Claim** . vSAN will automatically claim all compatible
devices on cluster hosts.

5. Group by host.

6. Select compatible disks to claim.

7. Click **Create** to confirm your selections.

The disk management page appears with the hosts listed. There will be an indication that disks are claimed on the
hosts in the **Disks in use** column reflecting the updated number of disks per host. To see the claimed disks for the
host, click **View disks** .

**Create a Disk Group on a Host (vSAN OSA)**
You can claim cache and capacity devices to define disk groups on a vSAN host. Select one cache device and one or
more capacity devices to create the disk group. vSAN OSA uses a tiered storage architecture comprised of disk group
constructs.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Disk Management** .

4. Select a host from the list, and click **View Disks** .

5. Click **Create Disk Group** .

6. Select disks to claim.

1. Select one flash device to use for the cache tier.
2. Select at least one disks for the capacity tier.

7. Click **Create** to confirm your selections.

The new disk group appears in the list.

**Claim Storage Devices for vSAN Express Storage Architecture Cluster**


You can select a group of devices from an ESXi host, and vSAN organizes them into a storage pool.

After vSAN ESA is enabled, you can claim disks either manually or automatically. In the manual method, you can select a
group of storage devices to be claimed.


VMware by Broadcom 1764


VMware Cloud Foundation 9.0


In automatic disk claim, vSAN automatically selects all compatible disks from the hosts. When new hosts are added to
the cluster, vSAN automatically claims the compatible disks available in those hosts and adds the storage to the vSAN
datastore.

You can choose devices that are not reported as certified for vSAN ESA and those devices will be considered in the
storage pool, but such configuration is not recommended and can impact performance.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Disk Management** .

4. To manually claim disks, click **Claim Unused Disks** .

a) Select the devices you want to claim
b) Click **Create** .

5. To automatically claim disks, click **Change Disk Claim Mode** and click the **vSAN managed disk claim** toggle button.

**Note:**

If you chose to use vSAN managed disk claiming when configuring the cluster, the toggle button would be already
enabled.

vSAN claims the devices that you selected and organizes them into storage pools that support the vSAN datastore.
By default, vSAN creates one storage pool for each ESXi host that contributes storage to the cluster. If the selected
devices are not certified for vSAN ESA, those devices are not considered for creating storage pools.

**Claim Storage Devices for vSAN Original Storage Architecture Cluster**


You can select a group of cache and capacity devices, and vSAN organizes them into default disk groups.

In this method, you select devices to create disk groups for the vSAN cluster. You need one cache device and at least one
capacity device for each disk group.


VMware by Broadcom 1765


VMware Cloud Foundation 9.0


1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Disk Management** .

4. Click **Claim Unused Disks** .

5. Select devices to add to disk groups.

  - For hybrid disk groups, each host that contributes storage must contribute one flash cache device and one or more
HDD capacity devices. You can add only one cache device per disk group.

    - Select a flash devices to be used as cache and click **Claim for cache tier** .

    - Select one or more HDD device to be used as capacity and click **Claim for capacity tier** for each of them.

    - Click **Create** or **OK** .

  - For all-flash disk groups, each host that contributes storage must contribute one flash cache device and one or
more flash capacity devices. You can add only one cache device per disk group.

    - Select one or more flash devices to be used as cache and click **Claim for cache tier** for reach of them.

    - Select a flash device to be used for capacity and click **Claim for capacity tier** .

    - Click **Create** or **OK** .

vSAN claims the devices that you selected and organizes them into default disk groups that contribute the vSAN
datastore.

To verify the role of each device added to the all-flash disk group, navigate to the "Claimed as" column for a given host
on the Disk Management page. The table shows the list of devices and their purpose in a disk group. For all-flash and
hybrid disk groups, the cache disk is always shown first in the disk group grid.

**Claim Disks for vSAN Direct**


You can claim local storage devices as vSAN Direct for use with the vSAN Data Persistence Platform.

**Note:**

Only the vSAN Data Persistence platform can consume vSAN Direct storage. The vSAN Data Persistence platform
provides a framework for software technology partners to integrate with Broadcom infrastructure. Each partner must
develop their own plug-in for Broadcom customers to receive the benefits of the vSAN Data Persistence platform. The
platform is not operational until the partner solution running on top is operational. For more information, see the _vSphere_
_Supervisor Concepts_ guide.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Disk Management** .

4. Click **Claim Unused Disks** .

5. On the Claim Unused Disks dialog, select the vSAN Direct tab.

6. Select a device to claim by selecting the checkbox in the **Claim for vSAN Direct** column.

**Note:**

Devices claimed for your vSAN cluster do not appear in the vSAN Direct tab.

7. Click **Create** .


For each device you claim, vSAN creates a new vSAN Direct datastore.

You can click the Datastores tab to display the vSAN Direct datastores in your cluster.


VMware by Broadcom 1766


VMware Cloud Foundation 9.0


**Working with Individual Devices in vSAN Cluster**

You can perform various device management tasks in the vSAN cluster.

You can add devices to a disk group, remove devices from a disk group, enable or disable locator LEDs, and mark
devices. You can also add or remove disks that are claimed using the vSAN Direct.


**Add Devices to the Disk Group in vSAN Cluster**


When you configure vSAN to claim disks in manual mode, you can add additional local devices to existing disk groups.

The devices must be the same type as the existing devices in the disk groups, such as SSD or magnetic disks.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Disk Management** .

4. Select the disk group, and click the **Add Disks** .

5. Select the device that you want to add and click **Add** .

If you add a used device that contains residual data or partition information, you must first clean the device. For
information about removing partition information from devices, see Remove Partition From Devices.

Verify that the vSAN Disk Balance health check is green. If the Disk Balance health check issues a warning, perform
automatic rebalance operation during off-peak hours. For more information, see Configure Automatic Rebalance in vSAN
Cluster.

**Check a Disk or Disk Group's Data Migration Capabilities from vSAN Cluster**


Use the data migration pre-check to find the impact of migration options when unmounting a disk or disk group, or
removing it from the vSAN cluster.

Run the data migration pre-check before you unmount or remove a disk or disk group from the vSAN cluster. The test
results provide information to help you determine the impact to cluster capacity, predicted health checks, and any objects
that will go out of compliance. If the operation will not succeed, pre-check provides information about what resources are
needed.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Monitor** tab.

3. Under vSAN, click **Data Migration Pre-check** .

4. Select a disk or disk group, choose a data migration option, and click **Pre-check** .

vSAN runs the data migration precheck tests.

5. View the test results.

The pre-check results show whether you can safely unmount or remove the disk or disk group.

  - The Object Compliance and Accessibility tab displays objects that might have issues after the data migration.

  - The Cluster Capacity tab displays the impact of data migration on the vSAN cluster before and after you perform
the operation.

  - The Predicted Health tab displays the health checks that might be affected by the data migration.

If the pre-check indicates that you can unmount or remove the device, click the option to continue the operation.


VMware by Broadcom 1767


VMware Cloud Foundation 9.0


**Remove Disk Groups or Devices from vSAN**


You can remove selected devices from a disk group, or you can remove an entire disk group from a vSAN OSA cluster.

Run data migration pre-check on the device or disk group before you remove it from the cluster.

Because removing unprotected devices might be disruptive for the vSAN datastore and virtual machines in the datastore,
avoid removing devices or disk groups.

Typically, you delete devices or disk groups from vSAN when you are upgrading a device or replacing a failed device, or
when you must remove a cache device. Other vSphere storage features can use any flash-based device that you remove
from the vSAN cluster.

Deleting a disk group permanently deletes the disk membership and the data stored on the devices.

**Note:** Removing one flash cache device or all capacity devices from a disk group removes the entire disk group.

**Note:** If the cluster uses deduplication and compression, you cannot remove a single disk from the disk group. You must
remove the entire disk group.

Evacuating data from devices or disk groups might result in the temporary noncompliance of virtual machine storage
policies.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

|Under vSAN, click Disk Management. Remove a disk group or selected devices. Option|Description|
|---|---|
|**Option**<br>|**Description**<br><br>|
|**Remove the Disk Group**<br>|1.<br>Under Disk Groups, select the disk group to remove, and<br>click**…**, then**Remove**.<br>2.<br>Select a data evacuation mode.<br><br>|
|**Remove the Selected Device**|1.<br>Under Disk Groups, select the disk group that contains the<br>device that you are removing.<br>2.<br>Under Disks, select the device to remove, and click the<br>**Remove Disk(s)**.<br>3.<br>Select a data evacuation mode.|



5. Click **Yes** or **Remove** to confirm.

The data is evacuated from the selected devices or disk group. You can use locator LEDs to identify the location of
storage devices. For more information, see Using Locator LEDs in vSAN.

**Recreate a Disk Group in vSAN Cluster**


When you recreate a disk group in the vSAN cluster, the existing disks are removed from the disk group, and the disk
group is deleted.

vSAN recreates the disk group with the same disks. When you recreate a disk group on a vSAN cluster, vSAN manages
the process for you. vSAN evacuates data from all disks in the disk group, removes the disk group, and creates the disk
group with the same disks.


VMware by Broadcom 1768


VMware Cloud Foundation 9.0


1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Disk Management** .

4. Under Disk Groups, select the disk group to recreate.

5. Click **…**, then click the **Recreate** .

The Recreate Disk Group dialog box appears.

6. Select a data migration mode, and click **Recreate** .


All data residing on the disks is evacuated. The disk group is removed from the cluster, and recreated.

**Using Locator LEDs in vSAN**


You can use locator LEDs to identify the location of storage devices.

vSAN can light the locator LED on a failed device so that you can easily identify the device. This is particularly useful
when you are working with multiple hot plug and host swap scenarios.

Consider using I/O storage controllers with pass-through mode, because controllers with RAID 0 mode require additional
steps to enable the controllers to recognize locator LEDs.

For information about configuring storage controllers with RAID 0 mode, see your vendor documentation.


**Locator LEDs**
You can turn locator LEDs on vSAN storage devices on or off. When you turn on the locator LED, you can identify the
location of a specific storage device.

- Verify that you have installed the supported drivers for storage I/O controllers that enable this feature. For
information about the drivers that are certified by Broadcom, see the _Brodcom Compatibility Guide_ [at https://](https://compatibilityguide.broadcom.com/)
[compatibilityguide.broadcom.com/.](https://compatibilityguide.broadcom.com/)

- In some cases, you might need to use third-party utilities to configure the Locator LED feature on your storage I/O
controllers. For example, when you are using HP you should verify that the HP SSA CLI is installed.

When you no longer need a visual alert on your vSAN devices, you can turn off locator LEDs on the selected devices.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Disk Management** .

4. Select a host to view the list of devices.









|At the bottom of the page, select one or more storage devic locator LEDs. Option|ces from the list, and perform the desired action for the Action|
|---|---|
|**Option**<br>|**Action**<br>|
|**Turn on LED**<br>|Turns on locator LED on the selected storage device. You also<br>can use the**Manage** tab and click**Storage** >**Storage Devices**.<br>|
|**Turn off LED**|Turns off locator LED on the selected storage device. You also<br>can use the**Manage** tab and click**Storage** >**Storage Devices**.|


**Mark Devices as Flash in vSAN**


When flash devices are not automatically identified as flash by ESXi hosts, you can manually mark them as local flash
devices.


VMware by Broadcom 1769


VMware Cloud Foundation 9.0


- Verify that the device is local to your ESXi host.

- Verify that the device is not in use.

- Make sure that the virtual machines accessing the device are powered off and the datastore is unmounted.

Flash devices might not be recognized as flash when they are enabled for RAID 0 mode rather than passthrough mode.
When devices are not recognized as local flash, they are excluded from the list of devices offered for vSAN and you
cannot use them in the vSAN cluster. Marking these devices as local flash makes them available to vSAN.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Disk Management** .

4. Select the host to view the list of available devices.

5. From the **Show** drop-down menu at the bottom of the page, select **Not in Use** .

6. Select one or more flash devices from the list and click the **Mark as Flash Disk** .

7. Click **Yes** to save your changes.

The Drive type for the selected devices appears as Flash.

**Mark Devices as HDD in vSAN**


When local magnetic disks are not automatically identified as HDD devices by ESXi hosts, you can manually mark them
as local HDD devices.

- Verify that the magnetic disk is local to your ESXi host.

- Verify that the magnetic disk is not in use and is empty.

- Verify that the virtual machines accessing the device are powered off.

If you marked a magnetic disk as a flash device, you can change the disk type of the device by marking it as a magnetic
disk.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Disk Management** .

4. Select the host to view the list of available magnetic disks.

5. From the **Show** drop-down menu at the bottom of the page, select **Not in Use** .

6. Select one or more magnetic disks from the list and click **Mark as HDD Disk** .

7. Click **Yes** to save.

The Drive Type for the selected magnetic disks appears as HDD.

**Mark Devices as Local in vSAN**


When ESXi hosts are using external SAS enclosures, vSAN might recognize certain devices as remote and might be
unable to automatically claim them as local.

Make sure that the storage device is not shared.

In such cases, you can mark the devices as local.


VMware by Broadcom 1770


VMware Cloud Foundation 9.0


1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Disk Management** .

4. Select a host to view the list of devices.

5. From the **Show** drop-down menu at the bottom of the page, select **Not in Use** .

6. From the list of devices, select one or more remote devices that you want to mark as local and click the **Mark as local**

**disk** .

7. Click **Yes** to save your changes.

**Mark Devices as Remote in vSAN**


ESXi hosts that use external SAS controllers can share devices.

You can manually mark those shared devices as remote, so that vSAN does not claim the devices when it creates disk
groups. In vSAN, you cannot add shared devices to a disk group.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Disk Management** .

4. Select a host to view the list of devices.

5. From the **Show** drop-down menu at the bottom of the page, select **Not in Use** .

6. Select one or more devices that you want to mark as remote and click the **Mark as remote** .

7. Click **Yes** to confirm.

**Add a Capacity Device to vSAN Disk Group**


You can add a capacity device to an existing vSAN disk group.

Verify that the device is formatted and is not in use.

You cannot add a shared device to a disk group.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Disk Management** .

4. Select a disk group.

5. Click the **Add Disks** at the bottom of the page.

6. Select the capacity device that you want to add to the disk group.

7. Click **OK** or **Add** .

The device is added to the disk group.

**Remove Partition From Devices**


You can remove partition information from a device so vSAN can claim the device for use.


VMware by Broadcom 1771


VMware Cloud Foundation 9.0


Verify that the device is not in use by ESXi as boot disk, VMFS datastore, or vSAN.

If you have added a device that contains residual data or partition information, you must remove all preexisting partition
information from the device before you can claim it for vSAN use. Broadcom recommends adding clean devices to disk
groups.

When you remove partition information from a device, vSAN deletes the primary partition that includes disk format
information and logical partitions from the device.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Disk Management** .

4. Select a host to view the list of available devices.

5. From the **Show** drop-down menu, select **Ineligible** .

6. Select a device from the list and click **Erase partitions** .

7. Click **OK** to confirm.

The device is clean and does not include any partition information.
### **Increasing Space Efficiency in a vSAN Cluster**

You can use space efficiency techniques to reduce the amount of space for storing data.

These techniques reduce the total storage space required to meet your needs.


**vSAN Space Efficiency Features**

You can use space efficiency techniques to reduce the amount of space for storing data.

These techniques reduce the total storage capacity required to meet your needs. vSAN supports SCSI unmap commands
that enable you to reclaim storage space that is mapped to a deleted vSAN object.

You can use deduplication and compression on a vSAN cluster to eliminate duplicate data and reduce the amount
of space required to store data. Or you can use compression-only vSAN to reduce storage requirements without
compromising server performance.

You can set the **Failure tolerance method** policy attribute on virtual machines to use RAID 5 or RAID 6 erasure coding.
Erasure coding can protect your data while using less storage space than the default RAID 1 mirroring.

You can use deduplication and compression, and RAID 5 or RAID 6 erasure coding to increase storage space savings.
RAID 5 or RAID 6 each provide clearly defined space savings over RAID 1. Deduplication and compression can provide
additional savings.


**Reclaiming Storage Space in vSAN with SCSI Unmap**

SCSI UNMAP commands enable you to reclaim storage space that is mapped to deleted files in the file system created by
the guest on the vSAN object.

Deleting or removing files frees space within the file system. This free space is mapped to a storage device until the file
system releases or unmaps it. vSAN supports reclamation of free space, which is also called the unmap operation. You
can free storage space in the vSAN datastore when you delete or migrate a virtual machine, consolidate a snapshot, and
so on.

Reclaiming storage space can provide a higher host-to-flash I/O throughput and improve the flash endurance.


VMware by Broadcom 1772


VMware Cloud Foundation 9.0


Unmap capability is not enabled by default. Enable **Guest Trim/Unmap** on the vSAN Services Advanced options tab.
When you enable unmap on a vSAN cluster, you must power off and then power on all virtual machines. Virtual machines
must use virtual hardware version 13 or above to perform unmap operations.

vSAN also supports the SCSI UNMAP commands issued directly from a guest operating system to reclaim storage space.
vSAN supports offline unmaps and inline unmaps. On Linux OS, offline unmaps are performed with the `fstrim(8)`
command, and inline unmaps are performed when the `mount -o discard` command is used. On Windows OS, NTFS
performs inline unmaps by default.


**Using Deduplication and Compression in vSAN Cluster**

vSAN can perform block-level deduplication and compression to save storage space.

When you enable deduplication and compression on a vSAN all-flash cluster, duplicate data within each disk group is
reduced. Deduplication removes redundant data blocks, whereas compression removes additional redundant data within
each data block. These techniques work together to reduce the amount of space required to store the data. vSAN applies
deduplication and then compression as it moves data from the cache tier to the capacity tier. Use compression-only vSAN
for workloads that do not benefit from deduplication, such as online transactional processing.

Deduplication occurs inline when data is written back from the cache tier to the capacity tier. The deduplication algorithm
uses a fixed block size and is applied within each disk group. Redundant copies of a block within the same disk group are
deduplicated.

For the vSAN OSA, deduplication and compression are enabled as a cluster-wide setting, but they are applied on a
disk group basis. Additionally, you cannot enable compression on specific workloads as the settings cannot be changed
through vSAN policies. When you enable deduplication and compression on a vSAN cluster, redundant data within a
particular disk group is reduced to a single copy.

**Note:**

Compression-only vSAN is applied on a per-disk basis.

For the vSAN ESA, compression is enabled by default on the cluster. If you do not want to enable compression on some
of your virtual machine workloads, you can do so by creating a customized storage policy and applying the policy to the
virtual machines. Additionally, compression for vSAN ESA is only for new writes. Old blocks are left uncompressed even
after compression is turned on for an object.

You can enable deduplication and compression when you create a vSAN all-flash cluster or when you edit an existing
vSAN all-flash cluster. For more information, see Enable Deduplication and Compression on an Existing vSAN Cluster.

When you enable or disable deduplication and compression, vSAN performs a rolling reformat of every disk group or
storage pool on every host. Depending on the data stored on the vSAN datastore, this process might take a long time. Do
not perform these operations frequently. If you plan to disable deduplication and compression, you must first verify that
enough physical capacity is available to place your data.

**Note:**

Deduplication and compression might not be effective for encrypted virtual machines, because virtual machine encryption
encrypts data on the host before it is written out to storage. Consider storage tradeoffs when using virtual machines
encryption.


**How to Manage Disks in a Cluster with Deduplication and Compression**

**Note:** This topic is applicable only for vSAN OSA cluster.

Consider the following guidelines when managing disks in a cluster with deduplication and compression enabled. These
guidelines do not apply to compression-only vSAN.


VMware by Broadcom 1773


VMware Cloud Foundation 9.0


- Avoid adding disks to a disk group incrementally. For more efficient deduplication and compression, consider adding a
disk group to increase the cluster storage capacity.

- When you add a disk group manually, add all the capacity disks at the same time.

- You cannot remove a single disk from a disk group. You must remove the entire disk group to make modifications.

- A single disk failure causes the entire disk group to fail.


**Verifying Space Savings from Deduplication and Compression**

The amount of storage reduction from deduplication and compression depends on many factors, including the type of
data stored and the number of duplicate blocks. Larger disk groups tend to provide a higher deduplication ratio. You can
check the results of deduplication and compression by viewing the Usage breakdown before dedup and compression in
the vSAN Capacity monitor.


You can view the Usage breakdown before dedup and compression when you monitor vSAN capacity in the vSphere
Client. It displays information about the results of deduplication and compression. The Used Before space indicates the
logical space required before applying deduplication and compression, while the Used After space indicates the physical
space used after applying deduplication and compression. The Used After space also displays an overview of the amount
of space saved, and the Deduplication and Compression ratio.

The Deduplication and Compression ratio is based on the logical (Used Before) space required to store data before
applying deduplication and compression, in relation to the physical (Used After) space required after applying
deduplication and compression. Specifically, the ratio is the Used Before space divided by the Used After space.
For example, if the Used Before space is 3 GbE, but the physical Used After space is 1 GbE, the deduplication and
compression ratio is 3x.

When deduplication and compression are enabled on the vSAN cluster, it might take several minutes for capacity updates
to be reflected in the Capacity monitor as disk space is reclaimed and reallocated.


**Deduplication and Compression Design Considerations in a vSAN Cluster**


Consider these guidelines when you configure deduplication and compression in a vSAN cluster.

- Deduplication and compression are available only on all-flash disk groups.

- On-disk format version 3.0 or later is required to support deduplication and compression.

- You must have a valid license to enable deduplication and compression on a cluster.


VMware by Broadcom 1774


VMware Cloud Foundation 9.0


- When you enable deduplication and compression on a vSAN cluster, all disk groups participate in data reduction
through deduplication and compression.

- vSAN can eliminate duplicate data blocks within each disk group, but not across disk groups (applicable only for vSAN
OSA).

- Capacity overhead for deduplication and compression is approximately five percent of total raw capacity.

- Policies must have either 0 percent or 100 percent object space reservations. Policies with 100 percent object space
reservations are always honored, but can make deduplication and compression less efficient.


**Enable Deduplication and Compression on a New vSAN Cluster**


You can enable deduplication and compression when you configure a new vSAN all-flash cluster.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, select **Services** .

a) Click **Edit** under **Data Services** .
b) Select a space efficiency option: Deduplication and compression, or Compression only.
c) Under **Encryption**, enable data-at-rest encryption by using the toggle button.

**Note:** If you use vSAN ESA cluster, you cannot change this setting after claiming disks.
d) (Optional) Select **Allow Reduced Redundancy** . If needed, vSAN reduces the protection level of your virtual

machines while enabling Deduplication and Compression. For more details, see Reduce Virtual Machine
Redundancy for vSAN Cluster.

4. Complete your cluster configuration.

**Enable Deduplication and Compression on an Existing vSAN Cluster**


You can enable deduplication and compression by editing configuration parameters on an existing all-flash vSAN cluster.

To enable on a vSAN OSA cluster:



1. In the vSphere Client, navigate to the cluster.
2. Click the **Configure** tab.
3. Under vSAN, select **Services**



a. Click to edit Space Efficiency.
b. Select a space efficiency option: Deduplication and compression, or Compression only.
c. (Optional) Select **Allow Reduced Redundancy** . If needed, vSAN reduces the protection level of your virtual



machines while enabling Deduplication and Compression. For more details, see Reduce Virtual Machine
Redundancy for vSAN Cluster.
4. Click **Apply** to save your configuration changes.



In a vSAN Express Storage Architecture cluster, vSAN enables compression by default using the vSAN storage policy.
Deduplication is not available on a vSAN ESA cluster.

While enabling deduplication and compression on a vSAN OSA cluster, vSAN updates the on-disk format of each disk
group of the cluster. To accomplish this change, vSAN evacuates data from the disk group, removes the disk group, and
recreates it with a new format that supports deduplication and compression.

The enablement operation does not require virtual machine migration or DRS. The time required for this operation
depends on the number of hosts in the cluster and amount of data. You can monitor the progress on the **Tasks and**
**Events** tab.


VMware by Broadcom 1775


VMware Cloud Foundation 9.0


**Disable Deduplication and Compression on vSAN Cluster**


You can disable deduplication and compression on your vSAN cluster.

When deduplication and compression are disabled on the vSAN cluster, the size of the used capacity in the cluster can
expand (based on the deduplication ratio). Before you disable deduplication and compression, verify that the cluster has
enough capacity to handle the size of the expanded data.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

a) Under vSAN, select **Services** .
b) Click **Edit** .
c) Disable Deduplication and Compression.
d) (Optional) Select **Allow Reduced Redundancy** . If needed, vSAN reduces the protection level of your virtual

machines, while disabling Deduplication and Compression. See Reduce Virtual Machine Redundancy for vSAN
Cluster.

3. Click **Apply** or **OK** to save your configuration changes.


While disabling deduplication and compression, vSAN changes the disk format on each disk group of the cluster.
It evacuates data from the disk group, removes the disk group, and recreates it with a format that does not support
deduplication and compression.

The time required for this operation depends on the number of hosts in the cluster and amount of data. You can monitor
the progress on the **Tasks and Events** tab.

**Reduce Virtual Machine Redundancy for vSAN Cluster**


When you enable deduplication and compression, in certain cases, you might need to reduce the level of protection for
your virtual machines.

Enabling deduplication and compression requires a format change for disk groups. To accomplish this change,
vSAN evacuates data from the disk group, removes the disk group, and recreates it with a new format that supports
deduplication and compression.

In certain environments, your vSAN cluster might not have enough resources for the disk group to be fully evacuated.
Examples for such deployments include a three-node cluster with no resources to evacuate the replica or witness while
maintaining full protection. Or a four-node cluster with RAID-5 objects already deployed. In the latter case, you have no
place to move part of the RAID-5 stripe, since RAID-5 objects require a minimum of four nodes.

You can still enable deduplication and compression and use the Allow Reduced Redundancy option. This option keeps
the virtual machines running, but the virtual machines might be unable to tolerate the full level of failures defined in the
virtual machine storage policy. As a result, temporarily during the format change for deduplication and compression, your
virtual machines might be at risk of experiencing data loss. vSAN restores full compliance and redundancy after the format
conversion is completed.


**Add or Remove Disks with Deduplication and Compression Enabled**


When you add disks to a vSAN cluster with enabled deduplication and compression, specific considerations apply.

- You can add a capacity disk to a disk group with enabled deduplication and compression. However, for more efficient
deduplication and compression, instead of adding capacity disks, create a new disk group to increase cluster storage
capacity.


VMware by Broadcom 1776


VMware Cloud Foundation 9.0


- When you remove a disk from a cache tier, the entire disk group is removed. Removing a cache tier disk when
deduplication and compression are enabled triggers data evacuation.

- Deduplication and compression are implemented at a disk group level. You cannot remove a capacity disk from the
cluster with enabled deduplication and compression. You must remove the entire disk group.

- If a capacity disk fails, the entire disk group becomes unavailable. To resolve this issue, identify and replace the failing
component immediately. When removing the failed disk group, use the No Data Migration option.


**Using RAID 5 or RAID 6 Erasure Coding in vSAN Cluster**

You can use RAID 5 or RAID 6 erasure coding to protect against data loss and increase storage efficiency.

Erasure coding can provide the same level of data protection as mirroring (RAID 1), while using less storage capacity.
RAID 5 or RAID 6 erasure coding enables vSAN to tolerate the failure of up to two capacity devices in the datastore. You
can configure RAID 5 on all-flash clusters with four or more fault domains. You can configure RAID 5 or RAID 6 on allflash clusters with six or more fault domains.

RAID 5 or RAID 6 erasure coding requires less additional capacity to protect your data than RAID 1 mirroring. For
example, a virtual machine protected by a **Failures to tolerate** value of 1 with RAID 1 requires twice the virtual disk size,
but with RAID 5 it requires 1.33 times the virtual disk size. The following table shows a general comparison between RAID
1 and RAID 5 or RAID 6.


**Table 848: Capacity Required to Store and Protect Data at Different RAID Levels**












|RAID Configuration|vSAN Architecture|Failures to Tolerate|Data Size|Capacity Required|
|---|---|---|---|---|
|RAID 1 (mirroring)|ESA, OSA|1|100 GbE|200 GbE|
|RAID 5 (erasure coding)<br>with four fault domains|OSA|1|100 GbE|133 GbE|
|RAID 5 (erasure coding)<br>with five fault domains|ESA|1|100 GbE|125 GbE|
|RAID 5 (erasure coding)<br>with three fault domains|ESA|1|100 GbE|150 GbE|
|RAID 1 (mirroring)|ESA, OSA|2|100 GbE|300 GbE|
|RAID 6 (erasure coding)<br>with six fault domains|OSA|2|100 GbE|150 GbE|
|RAID 6 (erasure coding)<br>with six fault domains|ESA|2|100 GbE|150 GbE|



RAID 5 or RAID 6 erasure coding is a policy attribute that you can apply to virtual machine components. To use RAID 5,
set **Failure tolerance method** to **RAID-5/6 (Erasure Coding)** and **Failures to tolerate** to 1. To use RAID 6, set **Failure**
**tolerance method** to **RAID-5/6 (Erasure Coding)** and **Failures to tolerate** to 2. RAID 5 or RAID 6 erasure coding does
not support a **Failures to tolerate** value of 3.

To use RAID 1, set **Failure tolerance method** to **RAID-1 (Mirroring)** . RAID 1 mirroring requires fewer I/O operations to
the storage devices, so it can provide better performance. For example, a cluster resynchronization takes less time to
complete with RAID 1.

**Note:** In a vSAN stretched cluster, the **Failure tolerance method** of **RAID-5/6 (Erasure Coding)** applies only to the **Site**
**disaster tolerance** setting.

**Note:**

For a vSAN ESA cluster, depending on the number of fault domains that you use, the number of components listed under
**RAID 5** ( **Monitor** - **vSAN** - **Virtual Objects** - testVM > **View Placement Details** ) will vary. If six or more fault domains


VMware by Broadcom 1777


VMware Cloud Foundation 9.0


are available in the cluster, then five components will be listed under **RAID 5** . If five or fewer fault domains are available,
then three components will be listed.

For more information about configuring policies, see Using vSAN Policies.


**RAID 5 or RAID 6 Design Considerations in vSAN Cluster**

Consider these guidelines when you configure RAID 5 or RAID 6 erasure coding in a vSAN cluster.

- RAID 5 or RAID 6 erasure coding is available only on all-flash disk groups.

- On-disk format version 3.0 or later is required to support RAID 5 or RAID 6.

- You must have a valid license to enable RAID 5/6 on a cluster.

- You can achieve additional space savings by enabling deduplication and compression on the vSAN cluster.

### **Using Encryption in a vSAN Cluster**

You can encrypt data-in transit in your vSAN cluster, and encrypt data-at-rest in your vSAN datastore.

vSAN can encrypt data-in-transit across hosts in the vSAN cluster. Data-in-transit encryption protects data as it moves
around the vSAN cluster.

vSAN can encrypt data-at-rest in the vSAN datastore. Data-at-rest encryption protects data on storage devices, in case a
device is removed from the cluster.


**vSAN Data-In-Transit Encryption**

vSAN can encrypt data-in-transit, as it moves across hosts in your vSAN cluster.

vSAN can encrypt data-in-transit across hosts in the cluster. When you enable data-in-transit encryption, vSAN encrypts
all data and metadata traffic between hosts.

vSAN data-in-transit encryption has the following characteristics:

- vSAN uses AES-256 bit encryption on data-in-transit.

- vSAN data-in-transit encryption is not related to data-at-rest-encryption. You can enable or disable each one
separately.

- Forward secrecy is enforced for vSAN data-in-transit encryption.

- Traffic between data hosts and witness hosts is encrypted.

- File service data traffic between the VDFS proxy and VDFS server is encrypted.

- vSAN file services inter-host connections are encrypted.

vSAN uses symmetric keys that are generated dynamically and shared between hosts. Hosts dynamically generate an
encryption key when they establish a connection, and they use the key to encrypt all traffic between the hosts. You do not
need a key management server to perform data-in-transit encryption.

Each host is authenticated when it joins the cluster, ensuring connections only to trusted hosts are allowed. When a host
is removed from the cluster, its authentication certificate is removed.

vSAN data-in-transit encryption is a cluster-wide setting. When enabled, all data and metadata traffic is encrypted as it
transits across hosts.


**Enable Data-In-Transit Encryption on a vSAN Cluster**


You can enable data-in-transit encryption by editing the configuration parameters of a vSAN cluster.


VMware by Broadcom 1778


VMware Cloud Foundation 9.0


1. In the vSphere Client, navigate to an existing cluster.

2. Click the **Configure** tab.

3. Under vSAN, select **Services** .

4. Click the Data-In-Transit Encryption **Edit** button.

5. Click to enable **Data-In-Transit encryption**, and select a rekey interval.

6. Click **Apply** .


Encryption of data-in-transit is enabled on the vSAN cluster. vSAN encrypts all data moving across hosts and file service
inter-host connections in the cluster.


**vSAN Data-At-Rest Encryption**

vSAN can encrypt data-at-rest in your vSAN datastore.

When you enable data-at-rest encryption, vSAN encrypts data after all other processing, such as deduplication, is
performed. Data-at-rest encryption protects data on storage devices, in case a device is removed from the cluster.

Using encryption on your vSAN datastore requires some preparation. After your environment is set up, you can enable
data-at-rest encryption on your vSAN cluster.

Data-at-rest encryption requires an external Key Management Server (KMS) or a vSphere Native Key Provider. For more
[information about vSphere encryption, see the vSphere Security guide.](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/vsphere-security.html)

You can use an external Key Management Server (KMS), the vCenter system, and your ESXi hosts to encrypt data in
your vSAN cluster. vCenter requests encryption keys from an external KMS. The KMS generates and stores the keys, and
vCenter obtains the key IDs from the KMS and distributes them to the ESXi hosts.

vCenter does not store the KMS keys, but keeps a list of key IDs.


**How vSAN Data-At-Rest Encryption Works**


When you enable data-at-rest encryption, vSAN encrypts everything in the vSAN datastore.

All files are encrypted, so all virtual machines and their corresponding data are protected. Only administrators with
encryption privileges can perform encryption and decryption tasks. vSAN uses encryption keys as follows:

- vCenter requests an AES-256 Key Encryption Key (KEK) from the KMS. vCenter stores only the ID of the KEK, but not
the key itself.

- The ESXi host encrypts disk data using the industry standard AES-256 XTS mode. In vSAN OSA, each disk has a
different randomly generated Data Encryption Key (DEK). In vSAN ESA, all the disks in the cluster use the same DEK
to encrypt object data.

- Each ESXi host uses the KEK to encrypt its DEKs, and stores the encrypted DEKs on disk. The host does not store
the KEK on disk. If a host reboots, it requests the KEK with the corresponding ID from the KMS. The host can then
decrypt its DEKs as needed.

- A host key is used to encrypt core dumps, not data. All hosts in the same cluster use the same host key. When
collecting support bundles, a random key is generated to re-encrypt the core dumps. You can specify a password to
encrypt the random key.

When a host reboots, it does not mount its disk groups until it receives the KEK. This process can take several minutes
or longer to complete. You can monitor the status of the disk groups in the vSAN health service, under **Physical disks >**
**Software state health** .


VMware by Broadcom 1779


VMware Cloud Foundation 9.0



**Encryption Key Persistence**

Data-at-rest encryption can continue to function even when the key server is temporarily offline or unavailable. With key
persistence enabled, the ESXi hosts can persist the encryption keys even after a reboot.

Each ESXi host obtains the encryption keys initially and retains them in its key cache. If the ESXi host has a Trusted
Platform Module (TPM), the encryption keys are persisted in the TPM across reboots. The host does not need to request
encryption keys. Encryption operations can continue when the key server is unavailable, because the keys have persisted
in the TPM.

Use the following commands to enable key persistence on a cluster host.
```
 esxcli system settings encryption set --mode=TPM
 esxcli system security keypersistence enable
```

[For more information about encryption key persistence, see "Key Persistence Overview" in the vSphere Security guide.](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/vsphere-security.html)


**Using vSphere Native Key Provider**

vSAN supports vSphere Native Key Provider. If your environment is set up for vSphere Native Key Provider, you can use
it to encrypt virtual machines in your vSAN cluster. For more information, see "Configuring and Managing vSphere Native
[Key Provider" in the vSphere Security guide.](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/vsphere-security.html)

vSphere Native Key Provider does not require an external Key Management Server (KMS). vCenter generates the Key
Encryption Key and pushes it to the ESXi hosts. The ESXi hosts then generate Data Encryption Keys.

**Note:** If you use vSphere Native Key Provider, make sure you backup the Native Key Provider to ensure reconfiguration
tasks run smoothly.

vSphere Native Key Provider can coexist with an existing key server infrastructure.


**Design Considerations for vSAN Data-At-Rest Encryption**


Consider these guidelines when working with data-at-rest encryption.

- Do not deploy your KMS server on the same vSAN datastore that you plan to encrypt.

- Encryption is CPU intensive. AES-NI significantly improves encryption performance. Enable AES-NI in your BIOS.

- The witness host in a vSAN stretched cluster does not participate in vSAN encryption. The witness host does not store
customer data, only metadata, such as the size and UUID of vSAN object and components.
**Note:** If the witness host is an appliance running on another cluster, you can encrypt the metadata stored on it. Enable
data-at-rest encryption on the cluster that contains the witness host.

- Establish a policy regarding core dumps. Core dumps are encrypted because they can contain sensitive information. If
you decrypt a core dump, carefully handle its sensitive information. ESXi core dumps might contain keys for the ESXi
host and for the data on it.

 - Always use a password when you collect a `vm-support` bundle. You can specify the password when you generate



the support bundle from the vSphere Client or using the `vm-support` command.
The password recrypts core dumps that use internal keys to use keys that are based on the password. You
can later use the password to decrypt any encrypted core dumps that might be included in the support bundle.
Unencrypted core dumps or logs are not affected.

- The password that you specify during `vm-support` bundle creation is not persisted in vSphere components. You are



responsible for keeping track of passwords for support bundles.

- [Ensure that vSAN supports KMS. For more information, see the Supported KMS Vendors.](https://compatibilityguide.broadcom.com/search?program=kms&persona=live&column=partnerName&order=asc)

- Verify KMS is healthy before enabling encryption.

- Ensure that you use highly available KMS clusters.



VMware by Broadcom 1780


VMware Cloud Foundation 9.0


**Set Up the Standard Key Provider**


Use a standard key provider to distribute the keys that encrypt the vSAN datastore.

Before you can encrypt the vSAN datastore, you must set up a standard key provider to support encryption. That task
includes adding the KMS to vCenter and establishing trust with the KMS. vCenter provisions encryption keys from the key
provider.

[The KMS must support the Key Management Interoperability Protocol (KMIP) 1.1 standard. See the vSphere Compatibility](https://compatibilityguide.broadcom.com/)
[Matrices for details.](https://compatibilityguide.broadcom.com/)


**Add a KMS to vCenter**
You add a Key Management Server (KMS) to your vCenter system from the vSphere Client.

- Verify that the key server is in the _vSphere Compatibility Matrices_ and is KMIP 1.1 compliant.

 - Verify that you have the required privileges: **Cryptographer** . **ManageKeyServers**

- Connecting to a KMS by using only an IPv6 address is not supported.

- Connecting to a KMS through a proxy server that requires user name or password is not supported.

vCenter creates a KMS cluster when you add the first KMS instance. If you configure the KMS cluster on two or more
vCenters, make sure you use the same KMS cluster name.

**Note:**

Do not deploy your KMS servers on the vSAN cluster you plan to encrypt. If a failure occurs, hosts in the vSAN cluster
must communicate with the KMS.

- When you add the KMS, you are prompted to set this cluster as a default. You can later change the default cluster
explicitly.

- After vCenter creates the first cluster, you can add KMS instances from the same vendor to the cluster.

- You can set up the cluster with only one KMS instance.

- If your environment supports KMS solutions from different vendors, you can add multiple KMS clusters.

1. Navigate to vCenter.

2. Click **Configure** tab.

3. Browse the inventory list and select the vCenter instance.

4. Under Security, click **Key Providers** .

|Click Add KMS, specify the KMS information in the wizard, Option|and click OK. Value|
|---|---|
|<br>**Option**<br>|**Value**<br>|
|**KMS cluster**<br>|Select**Create new cluster** for a new cluster. If a cluster exists,<br>you can select that cluster.<br>|
|**Cluster name**<br>|Name for the KMS cluster. You can use this name to connect to<br>the KMS if your vCenter instance becomes unavailable.<br>|
|**Server alias**<br>|Alias for the KMS. You can use this alias to connect to the KMS<br>if your vCenter instance becomes unavailable.<br>|
|**Server address**<br>|IP address or FQDN of the KMS.<br>|
|**Server port**<br>|Port on which vCenter connects to the KMS.<br>|
|**Proxy address**<br>|Optional proxy address for connecting to the KMS.<br>|
|**Proxy port**<br>|Optional proxy port for connecting to the KMS.<br>|
|**User name**|Some KMS vendors allow users to isolate encryption keys that<br>are used by different users or groups by specifying a user name|



VMware by Broadcom 1781


VMware Cloud Foundation 9.0

|Option|Value|
|---|---|
||and password. Specify a user name only if your KMS supports<br>this functionality, and if you intend to use it.<br>|
|**Password**|Some KMS vendors allow users to isolate encryption keys that<br>are used by different users or groups by specifying a user name<br>and password. Specify a password only if your KMS supports<br>this functionality, and if you intend to use it.|



Establish a Standard Key Provider Trusted Connection by Exchanging Certificates
After you add the standard key provider to the vCenter system, you can establish a trusted connection.

Add the standard key provider.

The exact process depends on the certificates that the key provider accepts, and on your company policy.

1. Navigate to vCenter.

2. Click the **Configure** tab.

3. Under **Security**, select **Key Providers** .

4. Select the key provider.

The KMS for the key provider is displayed.

5. Select the KMS.

6. From the **Establish Trust** drop-down menu, select **Make KMS trust vCenter** .

7. Select the option appropriate for your server and follow the steps.

|Option|See|
|---|---|
|**vCenter Root CA certificate**<br>|Use the Root CA Certificate Option to Establish a Standard Key<br>Provider Trusted Connection.<br>|
|**vCenter Certificate**<br>|Use the Certificate Option to Establish a Standard Key Provider<br>Trusted Connection.<br>|
|**Upload certificate and private key**<br>|Use the Upload Certificate and Private Key Option to Establish a<br>Standard Key Provider Trusted Connection.<br>|
|**New Certificate Signing Request**|Use the New Certificate Signing Request Option to Establish a<br>Standard Key Provider Trusted Connection.|



Use the Root CA Certificate Option to Establish a Standard Key Provider Trusted Connection
Some Key Management Server (KMS) vendors require that you upload your root CA certificate to the KMS.

All certificates that are signed by your root CA are then trusted by this KMS. The root CA certificate that vSphere Virtual
Machine Encryption uses is a self-signed certificate that is stored in a separate store in the VMware Endpoint Certificate
Store (VECS) on the vCenter system.

**Note:** Generate a root CA certificate only if you want to replace existing certificates. If you do, other certificates that are
signed by that root CA become invalid. You can generate a new root CA certificate as part of this workflow.

1. Navigate to vCenter.

2. Click the **Configure** tab.

3. Under **Security**, select **Key Providers** .

4. Select the key provider with which you want to establish a trusted connection.

The key server (KMS) for the key provider is displayed.


VMware by Broadcom 1782


VMware Cloud Foundation 9.0


5. From the **Establish Trust** drop-down menu, select **Make KMS trust vCenter** .

6. Select **vCenter Root CA Certificate** and click **Next** .

The Download Root CA Certificate dialog box is populated with the root certificate that vCenter uses for encryption.
This certificate is stored in VECS.

7. Copy the certificate to the clipboard or download the certificate as a file.

8. Follow the instructions from your KMS vendor to upload the certificate to their system.

**Note:** Some KMS vendors require that the KMS vendor restarts the KMS to pick up the root certificate that you
upload.

Finalize the certificate exchange. See Finish the Trust Setup for a Standard Key Provider.

Use the Certificate Option to Establish a Standard Key Provider Trusted Connection
Some Key Management Server (KMS) vendors require that you upload the vCenter certificate to the KMS.

After the upload, the KMS accepts traffic that comes from a system with that certificate. vCenter generates a certificate
to protect connections with the KMS. The certificate is stored in a separate key store in the VMware Endpoint Certificate
Store (VECS) on the vCenter system.

1. Navigate to vCenter.

2. Click the **Configure** tab.

3. Under **Security**, select **Key Providers** .

4. Select the key provider with which you want to establish a trusted connection.

The key server (KMS) for the key provider is displayed.

5. From the **Establish Trust** drop-down menu, select **Make KMS trust vCenter** .

6. Select **vCenter Certificate** and click **Next** .

The Download Certificate dialog box is populated with the root certificate that vCenter uses for encryption. This
certificate is stored in VECS.

**Note:** Do not generate a new certificate unless you want to replace existing certificates.

7. Copy the certificate to the clipboard or download it as a file.

8. Follow the instructions from your KMS vendor to upload the certificate to the KMS.

Finalize the trust relationship. See Finish the Trust Setup for a Standard Key Provider.

Use the New Certificate Signing Request Option to Establish a Standard Key Provider Trusted Connection
Some Key Management Server (KMS) vendors require that vCenter generate a Certificate Signing Request (CSR) and
send that CSR to the KMS.

The KMS signs the CSR and returns the signed certificate. You can upload the signed certificate to vCenter. Using the
**New Certificate Signing Request** option is a two-step process. First you generate the CSR and send it to the KMS
vendor. Then you upload the signed certificate that you receive from the KMS vendor to vCenter.

1. Navigate to vCenter.

2. Click the **Configure** tab.

3. Under **Security**, select **Key Providers** .

4. Select the key provider with which you want to establish a trusted connection.

The key server (KMS) for the key provider is displayed.


VMware by Broadcom 1783


VMware Cloud Foundation 9.0


5. From the **Establish Trust** drop-down menu, select **Make KMS trust vCenter** .

6. Select **New Certificate Signing Request (CSR)** and click **Next** .

7. In the dialog box, copy the full certificate in the text box to the clipboard or download it as a file.

Use the **Generate new CSR** button in the dialog box only if you explicitly want to generate a CSR.

8. Follow the instructions from your KMS vendor to submit the CSR.

9. When you receive the signed certificate from the KMS vendor, click **Key Providers** again, select the key provider, and

from the **Establish Trust** drop-down menu, select **Upload Signed CSR Certificate** .

10. Paste the signed certificate into the bottom text box or click **Upload File** and upload the file, and click **Upload** .

Finalize the trust relationship. See Finish the Trust Setup for a Standard Key Provider.

Use the Upload Certificate and Private Key Option to Establish a Standard Key Provider Trusted Connection
Some Key Management Server (KMS) vendors require that you upload the KMS server certificate and private key to the
vCenter system.

- Request a certificate and private key from the KMS vendor. The files are X509 files in PEM format.

Some KMS vendors generate a certificate and private key for the connection and make them available to you. After you
upload the files, the KMS trusts your vCenter instance.

1. Navigate to vCenter.

2. Click the **Configure** tab.

3. Under **Security**, select **Key Providers** .

4. Select the key provider with which you want to establish a trusted connection.

The key server (KMS) for the key provider is displayed.

5. From the **Establish Trust** drop-down menu, select **Make KMS trust vCenter** .

6. Select **KMS certificate and private key** and click **Next** .

7. Paste the certificate that you received from the KMS vendor into the top text box or click **Upload a File** to upload the

certificate file.

8. Paste the key file into the bottom text box or click **Upload a File** to upload the key file.

9. Click **Establish Trust** .

Finalize the trust relationship. See Finish the Trust Setup for a Standard Key Provider.

**Set the Default Key Provider Using the vSphere Client**
You can use the vSphere Client to set the default key provider at the vCenter level.

As a best practice, verify that the Connection Status in the Key Providers tab shows Active and a green check mark.

You must set the default key provider if you do not make the first key provider the default, or if your environment uses
multiple key providers and you remove the default one.

1. Navigate to vCenter.

2. Click the **Configure** tab.

3. Under **Security**, select **Key Providers** .

4. Select the key provider.

5. Click **Set as Default** .

A confirmation dialog box appears.


VMware by Broadcom 1784


VMware Cloud Foundation 9.0


6. Click **Set as Default** .

The key provider displays as the current default.

**Finish the Trust Setup for a Standard Key Provider**
Unless the **Add Standard Key Provider** dialog prompted you to trust the KMS, you must explicitly establish trust after
certificate exchange is complete.

You can complete the trust setup, that is, make vCenter trust the KMS, either by trusting the KMS or by uploading a KMS
certificate. You have two options:

- Trust the certificate explicitly by using the **Upload KMS certificate** option.

- Upload a KMS leaf certificate or the KMS CA certificate to vCenter by using the **Make vCenter Trust KMS** option.

**Note:** If you upload the root CA certificate or the intermediate CA certificate, vCenter trusts all certificates that are signed
by that CA. For strong security, upload a leaf certificate or an intermediate CA certificate that the KMS vendor controls.

1. Navigate to vCenter.

2. Click the **Configure** tab.

3. Under **Security**, select **Key Providers** .

4. Select the key provider with which you want to establish a trusted connection.

The key server (KMS) for the key provider is displayed.

5. Select the KMS.

|Option|Action|
|---|---|
|**Make vCenter Trust KMS**<br>|In the dialog box that appears, click**Trust**.<br><br>|
|**Upload KMS certificate**|1.<br>In the dialog box that appears, either paste in the certificate,<br>or click**Upload a file** and browse to the certificate file.<br>2.<br>Click**Upload**.|



**Enable Encryption on a New vSAN Cluster**


You can enable encryption when you configure a new vSAN cluster.

- Required privileges:

 - **Host** . **Inventory** . **EditCluster**

 - **Cryptographer** . **ManageEncryptionPolicy**

 - **Cryptographer** . **ManageKeyServers**

 - **Cryptographer** . **ManageKeys**

- You must have set up a KMS cluster and established a trusted connection between vCenter and the KMS.

1. In the vSphere Client, navigate to an existing cluster.

2. Click the **Configure** tab.

3. Under vSAN, select **Services.**

4. Click **Data Services** and click **Edit** .

5. Click the **Configure vSAN** button.

6. On the **vSAN capabilites** page, select the **Encryption** check box, and select a KMS cluster.

**Note:** Make sure the **Erase disks before use** check box is deselected, unless you want to wipe existing data from
the storage devices as they are encrypted.


VMware by Broadcom 1785


VMware Cloud Foundation 9.0


7. On the **Claim disks** page, specify which disks to claim for the vSAN cluster.

a)
Select a flash device to be used for capacity and click the **Claim for capacity tier** icon ( ).
b)
Select a flash device to be used as cache and click the **Claim for cache tier** icon ( ).

8. Complete your cluster configuration.


Encryption of data-at-rest is enabled on the vSAN cluster. vSAN encrypts all data added to the vSAN datastore.

**Generate New Encryption Keys**


You can generate new encryption keys, in case a key expires or becomes compromised.

- Required privileges:

 - **Host** . **Inventory** . **EditCluster**

 - **Cryptographer** . **ManageKeys**

- You must have set up a KMS cluster and established a trusted connection between vCenter and the KMS.

The following options are available when you generate new encryption keys for your vSAN cluster.

- If you generate a new KEK, all hosts in the vSAN cluster receive the new KEK from the KMS. Each host's DEK is reencrypted with the new KEK.

- If you choose to re-encrypt all data using new keys, a new KEK and new DEKs are generated. A rolling disk re-format
is required to re-encrypt data.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, select **Services** .

4. Click **Data Services** and click **Edit** .

5. In the vSAN is turned ON pane, click the **Generate new encryption keys** button.

6. To generate a new KEK, click **OK** . The DEKs will be re-encrypted with the new KEK.

  - To generate a new KEK and new DEKs, and re-encrypt all data in the vSAN cluster, select the following check box:
**Also re-encrypt all data on the storage using new keys** .

  - If your vSAN cluster has limited resources, select the **Allow Reduced Redundancy** check box. If you allow
reduced redundancy, your data might be at risk during the disk reformat operation.

**Enable vSAN Encryption on Existing vSAN Cluster**


You can enable encryption by editing the configuration parameters of an existing vSAN cluster.

- Required privileges:

 - **Host** . **Inventory** . **EditCluster**

 - **Cryptographer** . **ManageEncryptionPolicy**

 - **Cryptographer.ManageKeyServers**

 - **Cryptographer** . **ManageKeys**

- You must have set up a KMS cluster and established a trusted connection between vCenter and the KMS.

- The cluster's disk-claiming mode must be set to manual.


VMware by Broadcom 1786


VMware Cloud Foundation 9.0


1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, select **Services** .

4. Click **Data Services** and click **Edit** .

5. On the vSAN Services dialog, click **Data-At-Rest encryption** .

6. Select **Wipe residual data** check box to wipe existing data from the storage devices before the data is encrypted.

7. Select a key provider from the drop-down.

8. Click **Data-In-Transit encryption** to enable fault tolerance traffic encryption.

9. Select Default or Custom as the **Rekey interval** . You can specify the interval based on your selection.

10. Select **Allow reduced redundancy** check box to reduce the protection level of your VMs.

11. Click **Apply** .


A rolling reformat of all disks in the storage pool or disk groups in an OSA cluster takes places as vSAN encrypts all data
in the vSAN datastore.

**vSAN Encryption and Core Dumps**


If your vSAN cluster uses data-at-rest encryption, and if an error occurs on the ESXi host, the resulting core dump is
encrypted to protect data.

Core dumps that are included in the `vm-support` package are also encrypted.

**Note:** Core dumps can contain sensitive information. Follow your organization's data security and privacy policy when
handling core dumps.


**Core Dumps on ESXi Hosts**

When an ESXi host crashes, an encrypted core dump is generated and the host reboots. The core dump is encrypted with
the host key that is in the ESXi key cache. What you can do next depends on several factors.

- In most cases, vCenter retrieves the key for the ESXi host from the KMS and attempts to push the key to the ESXi
host after reboot. If the operation is successful, you can generate the `vm-support` package and you can decrypt or reencrypt the core dump.

- If vCenter cannot connect to the ESXi host, you might be able to retrieve the key from the KMS.

- If the host used a custom key, and that key differs from the key that vCenter pushes to the ESXi host, you cannot
manipulate the core dump. Avoid using custom keys.


**Core Dumps and vm-support Packages**

When you contact Broadcom Technical Support because of a serious error, your support representative usually asks
you to generate a `vm-support` package. The package includes log files and other information, including core dumps. If
support representatives cannot resolve the issues by looking at log files and other information, you can decrypt the core
dumps to make relevant information available. Follow your organization's security and privacy policy to protect sensitive
information, such as host keys.


**Core Dumps on vCenter Systems**

A core dump on a vCenter system is not encrypted. vCenter already contains potentially sensitive information. At the
minimum, ensure that the vCenter is protected. You also might consider turning off core dumps for the vCenter system.
Other information in log files can help determine the problem.


VMware by Broadcom 1787


VMware Cloud Foundation 9.0


**Collect a vm-support Package for an ESXi Host in an Encrypted vSAN Datastore**
If data-at-rest encryption is enabled on a vSAN cluster, any core dumps in the `vm-support` package are encrypted.

Inform your support representative that data-at-rest encryption is enabled for the vSAN datastore. Your support
representative might ask you to decrypt core dumps to extract relevant information.

**Note:** Core dumps can contain sensitive information. Follow your organization's security and privacy policy to protect
sensitive information such as host keys.

You can collect the package, and you can specify a password if you expect to decrypt the core dump later. The `vm-`
`support` package includes log files, core dump files, and more.

1. Log in to vCenter using the vSphere Client.

2. Click **Hosts and Clusters**, and right-click the ESXi host.

3. Select **Export System Logs** .

4. In the dialog box, select **Password for encrypted core dumps**, and specify and confirm a password.

5. Leave the defaults for other options or make changes if requested by Broadcom Technical Support, and click **Finish** .

6. Specify a location for the file.

7. If your support representative asked you to decrypt the core dump in the `vm-support` package, log in to any ESXi host



and follow these steps.
a) Log in to the ESXi and connect to the directory where the `vm-support` package is located.



The filename follows the pattern `esx.date_and_time.tgz` .
b) Make sure that the directory has enough space for the package, the uncompressed package, and the



recompressed package, or move the package.
c) Extract the package to the local directory.


```
     vm-support -x *.tgz .
```

The resulting file hierarchy might contain core dump files for the ESXi host, usually in `/var/core`, and might
contain multiple core dump files for virtual machines.
d) Decrypt each encrypted core dump file separately.
```
     crypto-util envelope extract --offset 4096 --keyfile vm-support-incident-key-file
     --password encryptedZdumpdecryptedZdump
```

_`vm-support-incident-key-file`_ is the incident key file that you find at the top level in the directory.

_`encryptedZdump`_ is the name of the encrypted core dump file.

_`decryptedZdump`_ is the name for the file that the command generates. Make the name similar to the
_`encryptedZdump`_ name.
e) Provide the password that you specified when you created the `vm-support` package.
f) Remove the encrypted core dumps, and compress the package again.
```
     vm-support --reconstruct
```

8. Remove any files that contain confidential information.

**Decrypt or Re-Encrypt an Encrypted Core Dump on ESXi Host**
You can decrypt or re-encrypt an encrypted core dump on your ESXi host by using the `crypto-util` CLI.

The ESXi host key that was used to encrypt the core dump must be available on the ESXi host that generated the core
dump.

You can decrypt and examine the core dumps in the `vm-support` package yourself. Core dumps might contain sensitive
information. Follow your organization's security and privacy policy to protect sensitive information, such as host keys.

For details about re-encrypting a core dump and other features of `crypto-util`, see the command-line help.


VMware by Broadcom 1788


VMware Cloud Foundation 9.0


**Note:** `crypto-util` is for advanced users.

1. Log directly in to the ESXi host on which the core dump occurred.

If the ESXi host is in lockdown mode, or if SSH access is not enabled, you might have to enable access first.

2. Determine whether the core dump is encrypted.

|Option|Description|
|---|---|
|Monitor core dump|`crypto-util envelope describe vmmcores.ve`|
|zdump file|`crypto-util envelope describe --offset 4096`_`zdump`_<br>_`File`_|



3. Decrypt the core dump, depending on its type.

|Option|Description|
|---|---|
|Monitor core dump|`crypto-util envelope extract vmmcores.ve vmmcores`|
|zdump file|`crypto-util envelope extract --offset 4096`_`zdumpEncr`_<br>_`yptedzdumpUnencrypted`_|


### **Upgrading the vSAN Cluster**

Upgrading vSAN is a multistage process, in which you must perform the upgrade procedures in the order described here.

**Note:**

You cannot upgrade a vSAN OSA cluster to a vSAN ESA cluster by using the vSphere Client.

Before you attempt to upgrade, make sure you understand the complete upgrade process clearly to ensure a smooth and
uninterrupted upgrade. If you are not familiar with the general vSphere upgrade procedure, you should first review the
_vCenter Upgrade_ guide.

**Note:** Failure to follow the sequence of upgrade tasks described here will lead to data loss and cluster failure.

The vSAN cluster upgrade proceeds in the following sequence of tasks.

1. [Upgrade the vCenter. See the vCenter Upgrade guide.](https://techdocs.broadcom.com/bin/gethidpage?ux-context-string=vsphclient_006&appid=vsphere-9-0&language=&format=rendered)
2. Upgrade the ESXi hosts. See Upgrade the ESX Hosts.
3. Upgrade the vSAN disk format. Upgrading the disk format is optional, but for best results, upgrade the objects to use

the latest version. The on-disk format exposes your environment to the complete feature set of vSAN.


**Before You Upgrade vSAN**

Plan and design your upgrade to be fail-safe.

Before you attempt to upgrade vSAN, verify that your environment meets the vSphere hardware and software
requirements.


**Upgrade Prerequisite**

[Consider the aspects that might delay the overall upgrade process. For guidelines and best practices, see the vCenter](https://techdocs.broadcom.com/bin/gethidpage?ux-context-string=vsphclient_006&appid=vsphere-9-0&language=&format=rendered)
[Upgrade guide.](https://techdocs.broadcom.com/bin/gethidpage?ux-context-string=vsphclient_006&appid=vsphere-9-0&language=&format=rendered)

Review the key requirements before you upgrade your cluster.


VMware by Broadcom 1789


VMware Cloud Foundation 9.0



**Table 849: Upgrade Prerequisite**







|Upgrade Prerequisites|Description|
|---|---|
|Software, hardware, drivers, firmware, and storage<br>I/O controllers|Verify that the new version of vSAN supports the software and hardware<br>components, drivers, firmware, and storage I/O controllers that you plan on using.<br>Supported items are listed on the_Broadcom Compatibility Guide_ athttps://compa<br>tibilityguide.broadcom.com/.|
|vSAN version|Verify that you are using the latest version of vSAN. You cannot upgrade from a<br>beta version to the new vSAN. When you upgrade from a beta version, you must<br>perform a fresh deployment of vSAN.|
|Disk space|Verify that you have enough space available to complete the software version<br>upgrade. The amount of disk storage needed for the vCenter installation depends<br>on your vCenter configuration.|
|vSAN disk format|vSAN disk format is a metadata upgrade that does not require data evacuation or<br>rebuilding.|
|vSAN hosts|Verify that you have placed the vSAN hosts in maintenance mode and selected<br>the**Ensure data accessibility** or**Evacuate all data** option.<br>You can use the vSphere Lifecycle Manager for automating and testing the<br>upgrade process. However, when you use vSphere Lifecycle Manager to upgrade<br>vSAN, the default evacuation mode is**Ensure data accessibility**. When you<br>use the**Ensure data accessibility**mode, your data is not protected, and if you<br>encounter a failure while upgrading vSAN, you might experience unexpected data<br>loss. However, the**Ensure data accessibility** mode is faster than the**Evacuate**<br>**all data** mode, because you do not need to move all data to another host in the<br>cluster.|
|Virtual Machines|Verify that you have backed up your virtual machines.|


**Recommendations**

Consider the following recommendations when deploying ESXi hosts for use with vSAN:

- If ESXi hosts are configured with memory capacity of 512 GbE or less, use SATADOM, SD, USB, or hard disk devices
as the installation media.

- If ESXi hosts are configured with memory capacity greater than 512 GbE, use a separate magnetic disk or flash device
as the installation device. If you are using a separate device, verify that vSAN is not claiming the device.

- When you boot a vSAN host from a SATADOM device, you must use a single-level cell (SLC) device and the size of
the boot device must be at least 16 GbE.

- To ensure your hardware meets the requirements for vSAN, see Hardware Requirements for vSAN.

vSAN 9.0 and later enables you to adjust the boot size requirements for an ESXi host in a vSAN cluster.


**Upgrading the Witness Host in a Two Host or vSAN Stretched Cluster**

The witness host for a two host cluster or vSAN stretched cluster is located outside of the vSAN cluster, but it is managed
by the same vCenter. You can use the same process to upgrade the witness host as you use for a vSAN data host.

Upgrade the witness host before you upgrade the data hosts.

Using vSphere Lifecycle Manager to upgrade hosts in parallel can result in the witness host being upgraded in parallel
with one of the data hosts. To avoid upgrade problems, configure vSphere Lifecycle Manager so it does not upgrade the
witness host in parallel with the data hosts.


VMware by Broadcom 1790


VMware Cloud Foundation 9.0


**Upgrade the vCenter**

This first task to perform during the vSAN upgrade is a general vSphere upgrade, which includes upgrading vCenter and
ESXi hosts.

VMware supports in-place upgrades on 64-bit systems. The vCenter upgrade includes a database schema upgrade and
an upgrade of the vCenter.

The details and level of support for an upgrade to ESXi depend on the host to be upgraded and the upgrade method
that you use. Verify that the upgrade path from your current version of ESXi to the version to which you are upgrading, is
[supported. For more information, see the Broadcom Product Interoperability Matrices.](https://compatibilityguide.broadcom.com/)

Instead of performing an in-place upgrade to vCenter, you can use a different machine for the upgrade. For detailed
[instructions and upgrade options, see the vCenter Upgrade guide.](https://techdocs.broadcom.com/bin/gethidpage?ux-context-string=vsphclient_006&appid=vsphere-9-0&language=&format=rendered)


**Upgrade the ESXi Hosts**

After you upgrade the vCenter, the next task for the vSAN cluster upgrade is upgrading the ESXi hosts to use the current
version.

You can upgrade the ESXi hosts in the vSAN cluster using:

- vSphere Lifecycle Manager - By using images or baselines, vSphere Lifecycle Manager enables you to upgrade ESXi
hosts in the vSAN cluster. The default evacuation mode is **Ensure data accessibility** . If you use this mode, and while
upgrading vSAN you encounter a failure, data can become inaccessible until one of the hosts is back online. For
information about working with evacuation and maintenance modes, see Working with Members of the vSAN Cluster in
[Maintenance Mode. For more information about upgrades and updates, see the Managing Host and Cluster Lifecycle](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/managing-host-and-cluster-lifecycle.html)
guide.

- Esxcli command - You can use components, base images, and add-ons as new software deliverables to update or
patch ESXi hosts using the manual upgrade.

When you upgrade a vSAN cluster with configured fault domains, vSphere Lifecycle Manager upgrades a host within
a single fault domain and then proceeds to the next host. This ensures that the cluster has the same vSphere versions
running on all the hosts. When you upgrade a vSAN stretched cluster, vSphere Lifecycle Manager upgrades all the hosts
from the preferred site and then proceeds to the host in the secondary site. This ensures that the cluster has the same
vSphere versions running on all the hosts.

[Before you attempt to upgrade the ESXi hosts, review the best practices discussed in the VMware ESX Upgrade guide.](https://techdocs.broadcom.com/bin/gethidpage?ux-context-string=vsphclient_008&appid=vsphere-9-0&language=&format=rendered)
Broadcom provides several ESXi upgrade options. Choose the upgrade option that works best with the type of host that
you are upgrading.

1. Upgrade the vSAN disk format.
2. Verify the host license. In most cases, you must reapply your host license.
3. Upgrade the virtual machines on the hosts by using the vSphere Client or vSphere Lifecycle Manager.


**About the vSAN Disk Format**

After you complete your ESXi update, upgrade the vSAN on-disk format to access the complete feature set of vSAN.

Each vSAN release supports the on-disk format of prior releases. All hosts in the cluster must have the same on-disk
format version. Because some features are tied to the on-disk format version, it's best to upgrade the vSAN on-disk format
to the highest version supported by the ESXi version. For more information, refer to the Broadcom knowledge base article
[2148493.](https://knowledge.broadcom.com/external/article/327034)

vSAN on-disk format version 3 and higher require only a metadata upgrade that takes a few minutes. No disk evacuation
or reconfiguration is performed during the on-disk format upgrade.


VMware by Broadcom 1791


VMware Cloud Foundation 9.0


Before you upgrade the vSAN on-disk format, run the **Pre-Check Upgrade** to ensure a smooth upgrade. The pre-check
identifies potential issues that might prevent a successful upgrade, such as failed disks or unhealthy objects.

**Note:** Once you upgrade the on-disk format, you cannot roll back software on the hosts or add certain older hosts to the
cluster.


**Upgrading vSAN Disk Format Using vSphere Client**


After you have finished upgrading the vSAN hosts, you can perform the disk format upgrade.

- Verify that you are using the updated version of vCenter.

- Verify that you are using the latest version of ESXi hosts.

- Verify that the disks are in a healthy state. Navigate to the Disk Management page to verify the object status.

- Verify that the hardware and software that you plan on using are certified and listed in the _Broadcom Compatibility_
_Guide_ [at https://compatibilityguide.broadcom.com/.](https://compatibilityguide.broadcom.com/)

- Verify that you have enough free space to perform the disk format upgrade.

- Verify that your hosts are not in maintenance mode. When upgrading the disk format, do not place the hosts in
maintenance mode. When any member host of a vSAN cluster enters maintenance mode, the member host no longer
contributes capacity to the cluster. The cluster capacity is reduced and the cluster upgrade might fail.

- Verify that there are no component rebuilding tasks currently in progress in the vSAN cluster. For information about
[vSAN resynchronization, see the vSphere Monitoring and Performance guide.](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/vsphere-monitoring-and-performance.html)

**Note:** If you enable encryption or deduplication and compression on an existing vSAN cluster, the on-disk format is
automatically upgraded to the latest version. This procedure is not required. See Edit vSAN Settings.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, select **Disk Management** .

4. (Optional) Click **Pre-check Upgrade** .

The upgrade pre-check analyzes the cluster to uncover any issues that might prevent a successful upgrade. Some of
the items checked are host status, disk status, network status, and object status. Upgrade issues are displayed in the
**Disk pre-check status** text box.

5. Click **Upgrade** .

6. Click **Yes** on the Upgrade dialog box to perform the upgrade of the on-disk format.


vSAN successfully upgrades the on-disk format. The On-disk Format Version column displays the disk format version of
storage devices in the cluster.

If a failure occurs during the upgrade, you can check the Resyncing Objects page. Wait for all resynchronizations to
complete, and run the upgrade again. You also can check the cluster health using the health service. After you have
resolved any issues raised by the health checks, you can run the upgrade again.

**Verify the vSAN Disk Format Upgrade**


After you finish upgrading the disk format, you must verify whether the vSAN cluster is using the new on-disk format.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Disk Management** .

The current disk format version appears in the Disk Format Version column.


VMware by Broadcom 1792


VMware Cloud Foundation 9.0


**About vSAN Object Format**

The operations space needed by vSAN to perform policy change or other such operations on an object created by vSAN
is the space used by a largest object in the cluster.

This is typically difficult to plan for and hence the guidance was to keep 30 percent of free space in the cluster assuming
that it is unlikely that the largest object in the cluster consumes more than 25 percent of the space and 5 percent of the
space is reserved to make sure cluster does not become full due to policy changes. In vSAN all objects are created in a
new format which allows the operations space needed by vSAN to perform policy change on an object if there is 255 GbE
per host for objects less than 8 TB and 765 GbE per host for objects 8 TB or larger.

After a cluster is upgraded, the objects greater than 255 GbE created with the older release must be rewritten in the new
format before vSAN can provide the benefit of being able to perform operations on an object with the new free space
requirements. A new object format health alert is displayed after an upgrade, if there are objects that must be fixed to the
new object format and allows the health state to be remediated by starting a relayout task to fix these objects. The health
alert provides information on the number of objects that must be fixed and the amount of data that will be rewritten. The
cluster might experience a drop of about 20 percent in the performance while the relayout task is in progress. The resync
dashboard provides more accurate information about the amount of time this operation takes to complete.


**Verify the vSAN Cluster Upgrade**

The vSAN cluster upgrade is not complete until you have verified that you are using the latest version of vSphere and
vSAN is available for use.

1. Navigate to the vSAN cluster.

2. Click the **Configure** tab, and verify that vSAN is listed.

  - You also can navigate to your ESXi host and select **Summary**   - **Configuration**, and verify that you are using the
latest version of the ESXi host.


**vSAN Build Recommendations for vSphere Lifecycle Manager**

vSAN generates system baselines and baseline groups that you can use with vSphere Lifecycle Manager.

vSphere Lifecycle Manager in vSphere includes the system baselines that Update Manager provided in earlier vSphere
releases. It also includes new image management functionality for hosts running ESXi.

vSAN generates automated build recommendations for vSAN clusters. vSAN combines information in the Broadcom
Compatibility Guide and vSAN Release Catalog with information about the installed ESXi releases. These recommended
updates provide the best available release to keep your hardware in a supported state.

System baselines for vSAN can include device driver and firmware updates. These updates support the ESXi software
recommended for your cluster.

For vSAN, you can choose to provide build recommendations for the current ESXi release only, or for the latest supported
ESXi release. A build recommendation for the current release includes all patches and driver updates for the release.

In vSAN, vSAN build recommendations include patch updates and applicable driver updates. To update firmware on vSAN
clusters, you must use an image through vSphere Lifecycle Manager.


**vSAN System Baselines**

vSAN build recommendations are provided through vSAN system baselines for vSphere Lifecycle Manager. These system
baselines are managed by vSAN. They are read-only and cannot be customized.

vSAN generates one baseline group for each vSAN cluster. vSAN system baselines are listed in the **Baselines** pane of
the Baselines and Groups tab. You can continue to create and remediate your own baselines.


VMware by Broadcom 1793


VMware Cloud Foundation 9.0


vSAN system baselines can include custom ISO images provided by certified vendors. If hosts in your vSAN cluster
have OEM-specific custom ISOs, then vSAN recommended system baselines can include custom ISOs from the same
vendor. vSphere Lifecycle Manager cannot generate a recommendation for custom ISOs not supported by vSAN. If you
are running a customized software image that overrides the vendor name in the host's image profile, vSphere Lifecycle
Manager cannot recommend a system baseline.

vSphere Lifecycle Manager automatically scans each vSAN cluster to check compliance against the baseline group. To
upgrade your cluster, you must manually remediate the system baseline through vSphere Lifecycle Manager. You can
remediate vSAN system baseline on a single host or on the entire cluster.


**vSAN Release Catalog**

The vSAN release catalog maintains information about available releases, preference order for releases, and critical
patches needed for each release. The vSAN release catalog is hosted on the VMware Cloud.

vSAN requires Internet connectivity to access the release catalog. You do not need to be enrolled in the Customer
Experience Improvement Program (CEIP) for vSAN to access the release catalog.

If you do not have an Internet connection, you can upload the vSAN release catalog directly to the vCenter. In the
vSphere Client, click **Configure** - **vSAN** - **Update**, and click **Upload from file** in the Release Catalog section. You can
download the latest vSAN Release Catalog.

vSphere Lifecycle Manager enables you to import storage controller drivers recommended for your vSAN cluster. Some
storage controller vendors provide a software management tool that vSAN can use to update controller drivers. If the
management tool is not present on ESXi hosts, you can download the tool.


**Working with vSAN Build Recommendations**

vSphere Lifecycle Manager checks the installed ESXi releases against information in the Hardware Compatibility List
(HCL) in the _Broadcom Compatibility Guide_ . It determines the correct upgrade path for each vSAN cluster, based on
the current vSAN Release Catalog. vSAN also includes the necessary drivers and patch updates for the recommended
release in its system baseline.

vSAN build recommendations ensure that each vSAN cluster remains at the current hardware compatibility status or
better. If hardware in the vSAN cluster is not included on the HCL, vSAN can recommend an upgrade to the latest release,
since it is no worse than the current state.

**Note:**

vSphere Lifecycle Manager uses the vSAN health service when performing remediation precheck for hosts in a vSAN
cluster. vSAN health service is not available on hosts running ESXi. When vSphere Lifecycle Manager upgrades hosts
running ESXi, the upgrade of the last host in the vSAN cluster might fail. If remediation failed because of vSAN health
issues, you can still complete the upgrade. Use the vSAN health service to resolve health issues on the host, then take
that host out of maintenance mode to complete the upgrade workflow.

The following examples describe the logic behind vSAN build recommendations.

**Example 1** A vSAN cluster is running, and its hardware is included on HCL.
The HCL lists the hardware supported. vSAN recommends an
upgrade, including the necessary critical patches for the release.
**Example 2** A vSAN cluster is running, and its hardware is included on HCL.
The hardware is also supported on the HCL. vSAN recommends
an upgrade.

**Example 3** A vSAN cluster is running, and its hardware is not on the HCL
for that release. vSAN recommends an upgrade, even though
the hardware is not on the HCL. vSAN recommends the upgrade
because the new state is no worse than the current state.


VMware by Broadcom 1794


VMware Cloud Foundation 9.0


**Example 4** A vSAN cluster is running, and its hardware is included on
HCL. The hardware is also supported on the HCL and selected
baseline preference is patch-only. vSAN recommends an upgrade,
including the necessary critical patches for the release.

The recommendation engine runs periodically (once each day), or when the following events occur.

- Cluster membership changes. For example, when you add or remove a host.

- The vSAN management service restarts.

- [A user logs in to Broadcom Support Portal using a web browser.](https://support.broadcom.com/)

- An update is made to the _Broadcom Compatibility Guide_ or the _vSAN Release Catalog_ .

The vSAN Build Recommendation health check displays the current build that is recommended for the vSAN cluster. It
also can warn you about any issues with the feature.


**System Requirements**

vSphere Lifecycle Manager is an extension service in vCenter 9.0 and later.

vSAN requires Internet access to update release metadata, to check the Broadcom Compatibility Guide, and to download
ISO images from Broadcom Support Portal. vSAN requires valid credentials to download ISO images for upgrades from
[Broadcom Support Portal.](https://support.broadcom.com/)

## **Monitoring and Troubleshooting vSAN**

_Monitoring and Troubleshooting vSAN_ describes how to monitor and troubleshoot VMware [®] vSAN [™] by using the vSphere
Client.

In addition, _Monitoring and Troubleshooting vSAN_ explains how to monitor and troubleshoot a vSAN cluster using esxcli
and other tools.

At VMware, we value inclusion. To foster this principle within our customer, partner, and internal community, we create
content using inclusive language.


**Intended Audience**

This guide is intended for anyone who wants to monitor vSAN operation and performance, or troubleshoot problems with
a vSAN cluster. The information in this guide is written for experienced system administrators who are familiar with virtual
machine technology and virtual datacenter operations. This manual assumes familiarity with VMware vSphere, including
VMware ESXi, vCenter, and the vSphere Client.

- For more information about network requirements and network design, see the Designing vSAN Network guide.

- For more information about creating vSAN clusters, see the Planning and Configuring vSAN guide.

- For more information about vSAN features and how to configure a vSAN cluster, see the Administering VMware vSAN
guide.
### **Monitoring the vSAN Cluster**

You can monitor the vSAN cluster and all the objects related to it.

You can monitor all of the objects in a vSAN environment, including ESXi hosts that participate in a vSAN cluster and the
[vSAN datastore. For more information about monitoring objects and storage resources in a vSAN cluster, see the vSphere](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/vsphere-monitoring-and-performance.html)
[Monitoring and Performance guide.](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/vsphere-monitoring-and-performance.html)


VMware by Broadcom 1795


VMware Cloud Foundation 9.0


**Monitor vSAN Capacity**

You can monitor the capacity of the vSAN datastore, vSAN Direct storage, and Persistent Memory (PMem) storage.

You can analyze usage and view the capacity breakdown at the cluster level.

The cluster Summary page includes a summary of vSAN capacity. You also can view more detailed information in the
Capacity monitor.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Monitor** tab.

3. Under vSAN, click **Capacity** to view the vSAN capacity information.


- The Capacity Overview displays the storage capacity of the vSAN datastore, including free space available,
used space, and the space that is actually written and physically consumed on the vSAN disks. For clusters that
have deduplication and compression enabled, you can view the deduplication and compression savings and the
deduplication and compression ratio.
**Note:** vSAN Express Storage Architecture (ESA) does not support deduplication.

|Terms|Description|
|---|---|
|Free space|Raw free space on the physical disks, without considering the<br>storage policy and overhead.|
|Used space|Total written physical space|
|Actually written|Actually used capacity. This capacity is displayed when<br>deduplication or compression are not enabled.|
|Space efficiency savings|Space saved when data compression is enabled.|
|Object reserved|Includes the reservation for objects created with a policy that has<br>specified object space reservation. This capacity is not actually<br>used by the objects.|
|Reserved capacity<br><br>|Includes the operations reserve and the ESXi host rebuild reserve.<br>|



**free space** is an estimate of free space available based on the selected storage policy. The effective free space
typically is smaller than the free space available on the disks. This can be due to the cluster topology or the distribution
of space across fault domains. For example, consider a cluster with 100 GB free space available on the disks.
However, 100 GB cannot be provisioned as a single 100 GB object due to the distribution of free space across fault
domains. If there are three fault domains and each fault domain has 33 GB free space, then the largest object that you
can create with FTT 1 is 33 GB.
Oversubscription reports the vSAN capacity required if all the thin provisioned VMs and user objects are used at
full capacity. It shows a ratio of the required usage compared with the total available capacity. While calculating the


VMware by Broadcom 1796


VMware Cloud Foundation 9.0


oversubscription, vSAN includes all the available VMs, user objects, and storage policy overhead, and does not
consider the vSAN namespace and swap objects.
**Note:**

Persistent Memory (PMem) storage does not support What if analysis and oversubscription.

 - The Usage breakdown before deduplication and compression displays the amount of storage space used by VMs,

user objects, and the system. You can view a pie chart that represents the different usage categories. Click the pie
chart to view the details of the selected category.
Following are the different usage categories available:

|Category|Description|
|---|---|
|VM (user objects) usage|Displays the following:<br>•<br>VM home objects - Usage of VM namespace object.<br>•<br>Swap objects - Usage of VM swap files.<br>•<br>VMDK - Capacity consumed by VMDK objects that reside<br>on the vSAN datastore that can be categorized as primary<br>data and replica usage. Primary data includes the actual user<br>data written into the physical disk which does not include any<br>overhead. Replica usage displays the RAID overhead for the<br>virtual disk.<br>•<br>VM memory snapshots - Usage of memory snapshot file for<br>VMs.<br>•<br>Block container volumes (attached to a VM) - Capacity<br>consumed by the container objects that are attached to a VM.<br>•<br>vSphere replication persistent state file - vSAN object used to<br>store the persistent state file (PSF) at source site.|
|Non-VM (user objects) usage|Displays iSCSI objects, block container volumes that are not<br>attached to VM, user-created files, ISO files, VM templates, files<br>shares, file container volumes, and vSAN objects used by the<br>vSphere replication service at the target site.|
|System usage|Displays the following:<br>•<br>Performance management objects - Capacity consumed by<br>objects created for storing performance metrics when you<br>enable the performance service.<br>•<br>File system overhead - vSAN on-disk format overhead that<br>may take up on the capacity drives.<br>•<br>ESA object overhead - vSAN ESA uses the capacity to store<br>object metadata and to provide high performance.<br>•<br>Checksum overhead - Overhead to store all the checksums in<br>vSAN OSA.<br>•<br>Dedup & compression overhead - Overhead to get the benefits<br>of deduplication and compression in vSAN OSA. This data is<br>visible only if you enable deduplication and compression.<br>•<br>Operations usage - Temporary space usage in a cluster. The<br>temporary space usage includes temporary capacity used for<br>rebalance operations or moving objects due to FTT changes.<br>•<br>Native trace objects - Capacity consumed by objects created<br>for storing vSAN traces.|



**Note:** PMEM only supports VMDK, Non-Volatile Dual In-line Memory Module (NVDIMM), and file system overhead.


VMware by Broadcom 1797


VMware Cloud Foundation 9.0


When you enable deduplication and compression, it might take several minutes to hours for capacity updates to be
reflected in the Capacity monitor, as disk space is reclaimed and reallocated. For more information about deduplication
and compression, see Using Deduplication and Compression in vSAN Cluster.

In vSAN ESA, Usage by Snapshots displays the snapshot usage by the vSAN datastore. You can delete one or more
snapshots and free the used space, thus managing space consumption. To delete a snapshot, right-click the virtual
machine > **Snapshots** - **Manage Snapshots** . Click **Delete** to delete a snapshot. Click **Delete All Snapshots** to delete all
the snapshots of the selected VM.

The following are the different usage snapshots available:

|Snapshot|Description|
|---|---|
|Container volume snapshots|Displays the container volume snapshot usage in the vSAN<br>datastore.|
|VMDK snapshots|Displays the VMDK snapshot usage in the vSAN datastore.|
|vSAN file share snapshots|Displays the file share snapshot usage in the vSAN datastore.|
|Current data|Displays the usage data that is not included in the snapshot usage<br>data. You can calculate the current data by subtracting the total<br>snapshot usage from the total used space.|



You can check the history of capacity usage in the vSAN datastore. Click **Capacity History**, specify a date or custom time
and date range, and click **Show Results** .

The Capacity monitor displays two thresholds represented as vertical markers in the bar chart:

- Operations threshold - Displays the space vSAN requires to perform internal operations in the cluster. If the used
space reaches beyond that threshold, vSAN might not be able to operate properly.

- Host rebuild threshold - Displays the space vSAN requires to tolerate one ESXi host failure. If the used space reaches
beyond the host rebuild threshold and the host fails, vSAN might not successfully restore all data from the failed host.

If you enable reserved capacity, the Capacity monitor displays the following:

- Operations reserve - Reserved space in the cluster for internal operations.

- Host rebuild reserve - Reserved space for vSAN to be able to repair objects in case of single ESXi host failure.
The Capacity monitor displays the host rebuild threshold only when the host rebuild reserve is enabled. For more
information, see About Reserved Capacity in vSAN Cluster.

If the resynchronization of objects is in progress in a cluster, vSAN displays the capacity used in the capacity chart as
operations usage. In case there is enough free space in the cluster, vSAN might use more space than the operations
threshold for the resyncing operations to complete faster.

Click **Configure** tab to enable the capacity reserve. You can also click **Configure** - **vSAN** - **Services** to enable the
capacity reserve. For more information on configuring the reserved capacity, see Configure Reserved Capacity for vSAN
Cluster.

In a cluster, if there is more utilization than the host rebuild threshold and the reserved capacity is not enabled, the
capacity chart turns yellow as a warning. If the most consumed host fails, vSAN cannot recover the data. If you enable
the host rebuild reserve, the capacity chart turns yellow at 80% of the host rebuild threshold. If the used space reaches
beyond the operations threshold and the reserved capacity is not enabled, vSAN cannot perform or complete operations
such as rebalance, resync object components due to policy changes, and so on. In that case, the capacity chart turns red
to indicate that the disk usage exceeds the operations threshold. For more information about capacity reserve, see About
Reserved Capacity for vSAN Cluster.


VMware by Broadcom 1798


VMware Cloud Foundation 9.0


**Monitor Physical Devices in vSAN Cluster**

You can monitor ESXi hosts, cache devices, and capacity devices used in the vSAN cluster.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Disk Management** to review all ESXi hosts, cache devices, and capacity devices in the cluster. The

physical location is based on the hardware location of cache and capacity devices on ESXi hosts.

The cache and capacity devices are available only in the vSAN OSA cluster.


**Monitor Devices that Participate in vSAN Datastores**

Verify the status of the devices that back up the vSAN datastore. You can check whether the devices experience any
problems.

1. In the vSphere Client, navigate to the vSAN datastore.

2. Select the vSAN datastore.

3. Click the **Configure** tab.

You can view general information about the vSAN datastore, including capacity, capabilities, and the default storage
policy.


**Monitor Virtual Objects in vSAN Cluster**

You can view the status of virtual objects in the vSAN cluster.

When one or more ESXi hosts are unable to communicate with the vSAN datastore, the information about virtual objects
might not be displayed.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Monitor** tab.

3. Under **vSAN**, select **Virtual Objects** to view the corresponding virtual objects in the vSAN cluster.



4.
Click to filter the virtual objects based on name, type, storage policy, and UUID.
a) Select the check box on one of the virtual objects and click **View Placement Details** to open the Physical



Placement dialog box. You can view the device information, such as name, identifier or UUID, number of devices
used for each virtual machine, and how they are distributed across ESXi hosts.
b) On the Physical Placement dialog box, select the **Group components by host placement** check box to organize



the objects by ESXi host and by disk.



**Note:**

At the cluster level, the Container Volumes filter displays detached container volumes. To view attached volumes,
expand the VM to which the container is attached.


VMware by Broadcom 1799


VMware Cloud Foundation 9.0


5. Select the check box of the attached block type or file volumes and click **View Performance** . You can use the

vSAN cluster performance charts to monitor the workload in your cluster. For more information on the vSAN cluster
performance charts, see View vSAN Cluster Performance.

6. Select the check box on one of the container volumes and click **View Container Volume** . For more information about

monitoring container volumes, see Monitor Container Volumes in vSAN Cluster.

7. Select the check box on one of the file volumes and click **View File Share** . For more information about file volume,

see View vSAN File Shares.


**Monitor Container Volumes in vSAN Cluster**

You can view the status of the container volumes in the vSAN cluster.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Monitor** tab.

3. Under **Cloud Native Storage**, select **Container Volumes** to view the container volumes in the vSAN cluster. You can

view information about the volume name, label, datastore, compliance status, health status, and capacity quota.



4.



Click to view the following:

- Click the **Basics** tab to view the volume details such as volume type, ID, datastore, storage policy, compliance, and
health status.

- Click the **Kubernetes objects** tab to view Kubernetes related data such as Kubernetes cluster, namespace, pod,
persistent volume claim, labels, and so on.

- Click the **Physical Placement** tab to view the type, ESXi host, cache, and capacity disk of the virtual object
components.

- Click the **Performance** tab to view the performance of the container volumes.



5. Select the check box for the volumes that have an out-of-date policy status that you can view under **Compliance**

**Status** column. Click **Reapply Policy** to reapply the policy on the selected volumes.

6. Select the check box for the container volume you want to delete and click **Delete** .

7. Click **Migrate** to migrate a container to a different datastore.

8. Use the **Add Filter** option to add filters to the container volumes.


**Migrate Container Volumes in vSAN Cluster**

You can migrate container volumes to a destination datastore in the vSAN cluster.


VMware by Broadcom 1800


VMware Cloud Foundation 9.0


1. In the vSphere Client, navigate to the cluster.

2. Click the **Monitor** tab.

3. Under **Cloud Native Storage**, select **Container Volumes** to view the container volumes in the vSAN cluster.

4. Click **Migrate** to migrate a container to a different datastore.

5. In the Migrate volume dialog box, you can view the volume storage policy and actual size of the volume.

6. Filter and select the destination datastore.

7. Select **I acknowledge that** check box as volume migration is an advanced operation.

8. Click **Migrate** .


**About Reserved Capacity in vSAN Cluster**

vSAN requires capacity for its internal operations.

For a cluster to be able to tolerate a single ESXi host failure, vSAN requires free space to restore the data of the failed
host. You can reserve the amount of the largest host to ensure that that the data can be recreated. These values are
represented as thresholds in the Capacity Monitor page:

- Operations threshold - Displays the space vSAN requires to run its internal operations in the cluster. If the used space
exceeds the operations threshold, vSAN might not operate properly.

- Host rebuild threshold - Displays the space vSAN requires to tolerate one host failure. If the used space exceeds the
host rebuild threshold and the host fails, vSAN might not successfully restore all data from the failed host.

For more information on the capacity thresholds, see Monitor vSAN Capacity.

**Note:**

The reserved capacity is not supported on a vSAN stretched cluster, cluster with fault domains and nested fault domains,
two-node cluster, or if the number of ESXi hosts in the cluster is less than four.

vSAN provides you the option to reserve the capacity in advance so that it has enough free space available to perform
internal operations and to repair data back to compliance following a single host failure. By enabling reserve capacity in
advance, vSAN prevents you from using the space to create workloads and intends to save the capacity available in a
cluster. By default, the reserved capacity is not enabled.

If there is enough free space in the vSAN cluster, you can enable the operations reserve and/or the host rebuild reserve.

- Operations reserve - Reserved space in the cluster for vSAN internal operations.

- Host rebuild reserve - Reserved space for vSAN to be able to repair in case of a single host failure.

These soft reservations prevent the creation of new VMs or powering on VMs if such operations consume the reserved
space. Once the reserved capacity is enabled, vSAN does not prevent powered on VM operations, such as I/O from the
guest operating system or applications from consuming the space even after the threshold limits are reached. After you
enable the reserved capacity, you must monitor the disk space health alerts and capacity usage in the cluster and take
appropriate actions to keep the capacity usage below the threshold limits.

To enable reserved capacity for the host rebuild, you must first enable the operations reserve. When you enable
operations reserve, vSAN reserves 5% additional capacity in the operations reserve as a buffer to ensure you have time
to react to the capacity fullness before the actual threshold is reached.

vSAN indicates when the capacity usage is high in a cluster. The indications can be in the form of health alerts, capacity
chart turning yellow or red, and so on. Due to the reservation, vSAN might not have enough free space left. This results in
the inability to create VMs or VM snapshots, creating or extending virtual disks, and so on.

**Note:** You cannot enable reserved capacity, if the cluster is at a capacity higher than the specified threshold.


VMware by Broadcom 1801


VMware Cloud Foundation 9.0


**Capacity Reservation Considerations**

Following are the considerations if you enable reserved capacity:

- When you enable reserved capacity with the host rebuild reserve and place a host into maintenance mode, the host
might not come back online. In this case, vSAN continues to reserve capacity for another host failure, on top of the one
already in maintenance mode. If the capacity usage exceeds the host rebuild threshold, this can cause operations to
fail.

- When you enable reserved capacity with the host rebuild reserve and a host fails, vSAN might not start repairing the
affected objects until the repair timer expires. During this time, vSAN continues to reserve capacity for another host
failure. This can cause failure of operations if the capacity usage is above the current host rebuild threshold, after the
first host failure. After the repairs are complete, you can deactivate the reserved capacity for the host rebuild reserve if
the cluster does not have the capacity for another host failure.


**Configure Reserved Capacity for vSAN Cluster**


You can configure reserved capacity for a vSAN cluster to reserve capacity for internal operations.

You can also configure reserve capacity to reserve capacity for data repair following a single ESXi host failure. Ensure
that you have the following required privileges: **Host.Inventory.EditCluster** and **Host.Config.Storage** .

Verify that the vSAN cluster:

- Is not configured as a vSAN stretched cluster or two-node cluster.

- Has no fault domains and nested fault domains created.

- Has a minimum of four ESXi hosts.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, select **Services** .

4. Click to edit the Reservations and Alerts.

5. Click to activate or deactivate the operations reserve. On enabling the operations reserve, vSAN ensures that the

cluster has enough space to complete the internal operations such as rebalancing, host rebuild, and so on.

6. Click to enable or deactivate the ESXi host rebuild reserve. On enabling the host rebuild reserve, vSAN provides the

reservation of space to repair data back to compliance following a single host failure. You can enable the host rebuild
reserve only after you enable the operations reserve. After enabling, if you deactivate the operations reserve, the host
rebuild reserve gets automatically deactivated.

7. Select **Customize alerts** . You can set a customized threshold to receive warning and error alerts. The threshold

percentage is calculated based on the available capacity, which is the difference between the total capacity and the
reserved capacity. If you do not set a customized value, vSAN uses the default thresholds to generate alerts.

8. Click **Apply** .


**About vSAN Cluster Resynchronization**

You can monitor the status of virtual machine objects that are being resynchronized in the vSAN cluster.


When a hardware device, ESXi host, or network fails, or if a ESXi host is placed into maintenance mode, vSAN initiates
resynchronization in the vSAN cluster. However, vSAN waits 60 minutes for the failed components to come back online
before initiating resynchronization tasks.

The following events trigger resynchronization in the cluster:


VMware by Broadcom 1802


VMware Cloud Foundation 9.0


- Editing a virtual machine (VM) storage policy. When you change VM storage policy settings, vSAN might initiate object
recreation and subsequent resynchronization of the objects.
Certain policy changes such as changing the stripe width might cause vSAN to create another version of an object and
synchronize it with the previous version. When the synchronization is complete, the original object is discarded.
vSAN ensures that VMs continue to run and are not interrupted by this process. This process might require additional
temporary capacity.

- Restarting an ESXi host after a failure.

- Recovering ESXi hosts from a permanent or long-term failure. If an ESXi host is unavailable for more than 60 minutes
(by default), vSAN creates copies of data to recover the full policy compliance.

- Evacuating data by using the full data migration mode before you place a ESXi host in maintenance mode.

- Exceeding the utilization threshold of a capacity device. Resynchronization is triggered when capacity device utilization
in the vSAN cluster approaches or exceeds the threshold level of 80 percent.

If a VM is not responding due to latency caused by resynchronization, you can throttle the IOPS used for
[resynchronization. For more information, see the Broadcom knowledge base article 326830.](https://knowledge.broadcom.com/external/article?articleNumber=326830)


**Monitor the Resynchronization Tasks in vSAN Cluster**


To evaluate the status of objects that are being resynchronized, you can monitor the resynchronization tasks that are
currently in progress.

Verify that ESXi hosts in your vSAN cluster are running ESXi 9.0 or later.

1. In the vSphere Client, navigate to the cluster.

2. Select the **Monitor** tab.

3. Under **vSAN** select **Resyncing Objects** .

4. Track the progress of resynchronization of virtual machine objects.

The object repair time defines the time vSAN waits before repairing a non-compliant object after placing an ESXi host
in a failed state or maintenance mode. The default setting is 60 minutes. To change the setting, edit the Object Repair
Timer ( **Configure > vSAN > Services > Advanced Options** ).

You can also view the following information about the objects that are resynchronized:

|Objects|Description|
|---|---|
|Total resyncing objects|Total number of objects to be resynchronized in the vSAN cluster.|
|Bytes left to resync|Data (in bytes) that is remaining before the resynchronization is<br>complete.|
|Total resyncing ETA|Estimated time left for the resynchronization to complete.<br>The objects to be resynchronized are categorized as active,<br>queued, and suspended. The objects that are actively<br>synchronizing fall in the active category. The objects that are in the<br>queue for resynchronization are the queued objects. The objects<br>that were actively synchronizing but are now in the suspended<br>state falls in the suspended category.|
|Scheduled resyncing|Remaining number of objects to be resynchronized.|



VMware by Broadcom 1803


VMware Cloud Foundation 9.0

|Objects|Description|
|---|---|
||You can classify scheduled resyncing into two categories:<br>scheduled and pending. The scheduled category displays the<br>objects that are not resyncing because the delay timer has not<br>expired. Resynchronization of objects starts once the timer<br>expires. The pending category displays the objects with the<br>expired delay timer that cannot be resynchronized. This can be<br>due to insufficient resources in the current cluster or the vSAN<br>FTT policy set on the cluster not being met.|



You can also view the resynchronization objects based on various filters such as **Intent** and **Status** . Using **Show first**,
you can modify the view to display the number of objects.


**About vSAN Cluster Rebalancing**

When any capacity device in your cluster reaches 80 percent full, vSAN automatically rebalances the data among the
other devices in the cluster.

The vSAN cluster rebalancing continues until the space and components available on all capacity devices is below the
threshold. Cluster rebalancing evenly distributes resources across the cluster to maintain consistent performance and
availability.

The following operations can cause disk capacity to reach 80% and initiate cluster rebalancing:

- Hardware failures occur on the cluster.

- ESXi hosts are placed in maintenance mode with the **Evacuate all data** option.

- ESXi hosts are placed in maintenance mode with **Ensure data accessibility** when objects assigned FTT=0 reside on
the host.

**Note:** To provide enough space for maintenance and reprotection, and to minimize automatic rebalancing events in the
vSAN cluster, consider enabling Operations Reserve or keeping 30-percent capacity available at all times.


**Configure Automatic Rebalance in vSAN Cluster**


vSAN automatically rebalances data on the disks by default. You can configure settings for automatic rebalancing.

Your vSAN cluster can become unbalanced based on the space or component usage for many reasons such as when
you create objects of different sizes, when you add new ESXi hosts or capacity devices, or when objects write different
amounts of data to the disks. If the cluster becomes unbalanced, vSAN automatically rebalances the disks. Based on the
space or component usage, this operation moves components from over-utilized disks to under-utilized disks.

You can enable or deactivate automatic rebalance, and configure the variance threshold for triggering an automatic
rebalance. If any two disks in the cluster have a variance in capacity or component usage that exceeds the rebalancing
threshold, vSAN begins rebalancing the cluster.

Disk rebalancing can impact the I/O performance of your vSAN cluster. By default the rebalance threshold is set at 30
percentage and ensures that the cluster remains relatively balanced without significantly impacting the performance. If
the cluster becomes severely imbalanced, such as after adding one or more hosts or disks, temporarily using a lower
threshold of 10 or 20 percentage makes the cluster evenly balanced. This must be done during off-peak periods to
minimize the performance impact during the rebalancing activity. Once the rebalancing is complete, you can change the
threshold back to the default 30 percentage.


VMware by Broadcom 1804


VMware Cloud Foundation 9.0


1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, select **Services** .

4. Under **Advanced Options** - click **Edit** .

5. Click to enable or deactivate Automatic Rebalance.

You can change the variance threshold to any percentage from 10 to 75.

You can use the vSAN Skyline Health to check the disk balance. Expand the Cluster category, and select vSAN **Disk**
**Balance** .


**Using the vSAN Default Alarms**

You can use the default vSAN alarms to monitor the cluster, ESXi hosts, and existing vSAN licenses.

The default alarms are automatically triggered when the events corresponding to the alarms are activated or if one or all
the conditions specified in the alarms are met. You cannot edit the conditions or delete the default alarms. To configure
alarms that are specific to your requirements, create custom alarms for vSAN. See Creating a vCenter Alarm for a vSAN
Event.

[For information about monitoring alarms, events, and editing existing alarm settings, see the vSphere Monitoring and](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/vsphere-monitoring-and-performance.html)
[Performance guide.](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/vsphere-monitoring-and-performance.html)


**View vSAN Default Alarms**


Use the default vSAN alarms to monitor your cluster, ESXi hosts, analyze any new events, and assess the overall cluster
health.

1. In the vSphere Client, navigate to the cluster.

2. Click **Configure** and then click **Alarm Definitions** .



3.



Click next to the **Alarm Name** and type **vSAN** in the search box to display the alarms that are specific to vSAN.

Type vSANHealth Service Alarm to search for vSAN health service alarms.

The default vSAN alarms are displayed.



4. From the list of alarms, click each alarm to view the alarm definition.

**View vSAN Network Alarms**


vSAN network diagnostics queries the latest network metrics and compares the metrics statistics with the defined
threshold values.

The vSAN performance service must be turned on.

If the value reaches above the threshold that you have set, vSAN network diagnostics raises an alarm. You must
acknowledge and manually reset the triggered alarms to green after fixing the network issues.


VMware by Broadcom 1805


VMware Cloud Foundation 9.0


1. In the vSphere Client, navigate to a host in the cluster.

2. Click the **Monitor** tab.

3. Under vSAN, select **Performance** .

4. Select **Physical Adapters**, and select a NIC. Select a time range for your query. vSAN displays performance charts

for the physical NIC (pNIC), including throughput, packets per second, and packets loss rate.

5.
Select . In the Threshold settings dialog box, enter a threshold value to receive warning and error alert.

6. Click **Save** .


vSAN displays the performance statistics of all the network I/Os in use. vSAN network diagnostics result appears in the
vCenter alerts. The redirection to the related performance charts is available in the vSAN network alerts generated by the
network diagnostics service.


**Using the VMkernel Observations for Creating vSAN Alarms**

VMkernel Observations (VOBs) are system events that you can use to set up vSAN alarms.

vSAN alarms are used for monitoring and troubleshooting performance and networking issues in the vSAN cluster. In
vSAN, these events are known as observations.


**VMware ESXi Observation IDs for vSAN**

Each VOB event is associated with an identifier (ID). Before you create a vSAN alarm in the vCenter, you must identify an
appropriate VOB ID for the vSAN event for which you want to create an alert. You can create alerts in the VMware ESXi
Observation Log file ( `vobd.log` ). For example, use the following VOB IDs to create alerts for any device failures in the
cluster.

- `esx.problem.vob.vsan.lsom.diskerror`

- `esx.problem.vob.vsan.pdl.offline`

To review the list of VOB IDs for vSAN, open `/usr/lib/vmware/hostd/extensions/hostdiag/locale/en/`
`event.vmsg` file located on your ESXi host in the `/var/log` directory. The log file contains the following VOB IDs that
you can use for creating vSAN alarms.


**Table 850: VOB IDs for vSAN**

|VOB ID|Description|
|---|---|
|esx.audit.vsan.clustering.enabled|The vSAN clustering service is enabled.|
|esx.clear.vob.vsan.pdl.online|The vSAN device has come online.|
|esx.clear.vsan.clustering.enabled|The vSAN clustering service is enabled.|
|esx.clear.vsan.vsan.network.available|vSAN has one active network configuration.|
|esx.clear.vsan.vsan.vmknic.ready|A previously reported vmknic has acquired a valid IP.|
|esx.problem.vob.vsan.lsom.componentthreshold|vSAN reaches the near node component count limit.|
|esx.problem.vob.vsan.lsom.diskerror|A vSAN device is in a permanent error state.|
|esx.problem.vob.vsan.lsom.diskgrouplimit|vSAN fails to create a disk group.|
|esx.problem.vob.vsan.lsom.disklimit|vSAN fails to add devices to a disk group.|
|esx.problem.vob.vsan.lsom.diskunhealthy|vSAN disk is unhealthy.|
|esx.problem.vob.vsan.pdl.offline|A vSAN device is offline.|



VMware by Broadcom 1806


VMware Cloud Foundation 9.0

|VOB ID|Description|
|---|---|
|esx.problem.vsan.clustering.disabled|vSAN clustering services are not enabled.|
|esx.problem.vsan.lsom.congestionthreshold|vSAN device memory or SSD congestion has been updated.|
|esx.problem.vsan.net.not.ready|A vmknic is added to vSAN network configuration without a valid IP address.<br>This happens when the vSAN network is not ready.|
|esx.problem.vsan.net.redundancy.lost|The vSAN network configuration does not have the required redundancy.|
|esx.problem.vsan.no.network.connectivity|vSAN does not have existing networking configuration, which is in use.|
|esx.problem.vsan.vmknic.not.ready|A vmknic is added to the vSAN network configuration without a valid IP address.|
|esx.problem.vob.vsan.lsom.devicerepair|The vSAN device is offline and in a repaired state because of I/O failures.|
|esx.problem.vsan.health.ssd.endurance|One or more vSAN disks exceed the warning usage of estimated endurance<br>threshold.|
|esx.problem.vsan.health.ssd.endurance.error|A vSAN disk exceeds the estimated endurance threshold.|
|esx.problem.vsan.health.ssd.endurance.warning|A vSAN disk exceeds 90% of its estimated endurance threshold.|



**Creating a vCenter Alarm for a vSAN Event**


You can create alarms to monitor events on the selected vSAN object, including the cluster, ESXi hosts, datastores,
networks, and virtual machines.

You must have the required privilege level of `Alarms.Create Alarm` or `Alarm.Modify Alarm`

1. In the vSphere Client, navigate to the cluster.

2. On the **Configure** tab, select **Alarm Definitions** and click **Add** .

3. In the Name and Targets page, enter a name and description for the new alarm.

4. From the **Target type** drop-down menu, select the type of inventory object that you want this alarm to monitor and

click **Next** .
Depending on the type of target that you choose to monitor, the summary that follows the **Targets**, change.

5. In the Alarm Rule page, select a trigger from the drop-down menu.

The combined event triggers are displayed. You can set the rule for a single event only. You must create multiple rules
for multiple events.


VMware by Broadcom 1807


VMware Cloud Foundation 9.0


6. Click **Add Argument** to select an argument from the drop-down menu.

a) Select an operator from the drop-down menu.
b) Select an option from the drop-down menu to set the threshold for triggering an alarm.
c) Select severity of the alarm from the drop-down menu. You can set the condition to either **Show as Warning** or

**Show as Critical**, but not for both. You must create a separate alarm definition for warning and critical status.

7. Select **Send email notifications**, to send email notifications when alarms are triggered.

a) Select the **Repeat** check box if you want to repeat the alarm in minutes at the specified interval.
b) In the **Subject** text box, enter the alarm name and target name.
c) In the **Email to** text box, enter recipient addresses. Use commas to separate multiple addresses.

8. Select **Send SNMP traps** to send traps when alarms are triggered on a vCenter instance.

9. Select the **Repeat** check box if you want to repeat the alarm in minutes at the specified interval.

10. Select **Run script** to run scripts when alarms are triggered.

11. Select the **Repeat** check box if you want to repeat the alarm in minutes at the specified interval.

12. Select an advanced action from the drop-down menu. You can define the advanced actions for virtual machine and

ESXi hosts. You can add multiple advanced actions for an alarm.

13. Click **Next** to set the Reset Rule.

14. Select **Reset the alarm to green** and select a trigger and a condition.

15. Click **Next** to review the alarm definition.

16. Click the **Repeat actions every** drop-down if you want to repeat the alarm in minutes at the specified interval.

17. Select **Enable this alarm** to enable the alarm and click **Create** .


The alarm is configured.
### **Monitoring vSAN Skyline Health**

You can check the overall health of the vSAN cluster, including hardware compatibility and networking configuration and
operations.

You can also check the advanced vSAN configuration options, storage device health, and virtual machine object health.


**About the vSAN Skyline Health**

Use the vSAN Skyline health to monitor the health of your vSAN cluster.

You can use the vSAN Skyline health to monitor the status of cluster components, diagnose issues, and troubleshoot
problems. The health findings cover hardware compatibility, network configuration and operation, advanced vSAN
configuration options, storage device health, and virtual machine objects.

You can use Overview to monitor the core health issues of your vSAN cluster. You can also view the following:

- Cluster health score based on the health findings

- View the health score trend for 24 hours

- View the health score trend for a particular period

Ensure that the **Historical Health Service** is enabled to view details of the Health score trend. Click **View Details** in the
Health score trend chart to examine the health state of the cluster for a selected time point within 24 hours. Use **Custom**
to customize the time range as per your requirement. If you disable **Historical Health Service**, the vSAN Skyline Health
score trend and the past health checks data gets deleted.

You can use the vSAN Health findings to diagnose issues, troubleshoot problems, and remediate the problems.


VMware by Broadcom 1808


VMware Cloud Foundation 9.0


The health findings are classified as follows:

- **Unhealthy** - Critical or important issue(s) being detected that needs attention.

- **Healthy** - There are no issues found that needs attention.

- **Info** - Health findings which may not impact the cluster running state but important for awareness.

- **Silenced** - Health findings have been silenced without triggering vSAN health alarm by intention.

To troubleshoot an issue, you can sort the findings by root cause to resolve the primary issues initially and then verify if
the impacted issues can also be resolved.

vSAN periodically retests each health finding and updates the results. To run the health findings and update the results
immediately, click the **Retest** button.

If you participate in the Customer Experience Improvement Program (CEIP), you can run health findings and send the
data to VMware for advanced analysis. Click **Retest with Online health** and then click **OK** . Online notifications is enabled
by default if the vCenter can connect to VMware Analytics Cloud without enrolling CEIP. If you do not want to participate in
CEIP, you can still receive vSAN health notifications for software and hardware issues using Online notifications.


**Viewing vSAN Health History**

The vSAN health history helps you examine health issues by querying the historical health records. You can only view
the historical health data of a cluster. By default, the health history is enabled. To deactivate the health history, select the
cluster and navigate to the **Configure** - **vSAN** - **Services** - **Historical Health Service** - **Edit** . Use the toggle **Enable**
**vSAN Historical Health Service** and click **Apply** to deactivate the health history. If you deactivate the health history, all
the health data collected on the vCenter database gets purged. The database stores the health data for up to 30 days
depending on the available capacity.

Using the Skyline Health view, you can view the health history for a selected time range. The start date of the time range
must not be earlier than 30 days from the current date. The end date must not be later than the current date. Based
on your selection, you can view the historical health findings. Click **View History Details** to view the history of a health
finding within a selected time period. The historical data is displayed as a graphical representation with green circles,
yellow triangles, and red squares showing success, warning, and failure respectively. The detailed information about each
health finding result is displayed in a table.


**Using vSAN Support Insight**

vSAN support insight is a platform that helps you maintain a reliable and consistent compute, storage, and network
environment. VMware support uses the vSAN support insight to monitor the vSAN performance diagnostics and resolve
performance issues. vSAN uses Customer Experience Improvement Program (CEIP) to send data to VMware for
analysis on a regular basis. To deactivate CEIP, click the icon next to **vSphere Client** - **Administration** - Deployment >
**Customer Experience Improvement Program** - **Leave Program** .


**Check vSAN Skyline Health**

You can view the status of vSAN health findings to verify the configuration and operation of your vSAN cluster.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Monitor** tab.

3. Under **vSAN**, select **Skyline Health** to review the vSAN health finding.

4. Under Health findings, perform the following:

  - Click **Unhealthy** to view the issues and the details. Click **Troubleshoot** to troubleshoot and fix an issue. You can
sort the findings by root cause to resolve the primary issues and then verify if the impacted issues can be resolved.
Click the **Ask VMware** button to open a knowledge base article that describes the health finding and provides


VMware by Broadcom 1809


VMware Cloud Foundation 9.0


information about how to resolve the issue. You can also view the status history of the health finding for a given
period using **History Details** tab.

  - Click **View History Details** to identify the status history of the health finding for a particular time period. The
default time period is 24 hours. You can also customize the time period as per your requirement. The status of an
unhealthy finding is displayed in yellow or red.

  - You can click **Silence alert** on a health finding, so it does not display any warnings or failures.

  - Click **All** to view health findings that are healthy. Click **View Current Result** to view the current status of the health
finding. Click **View History Details** to identify the status history of the health finding for a particular time period.
The status is displayed in green. You can also view the status history of the health finding for a given period using
**History Details** tab.


**Monitor vSAN from ESXi Host Client**

You can monitor vSAN health and basic configuration through the ESXi host client.

The ESXi host client is a browser-based interface for managing a single ESXi host. It enables you to manage the host
when vCenter is not available. The host client provides tabs for managing and monitoring vSAN at the host level.

- The **vSAN** tab displays basic vSAN configuration.

- The **Hosts** tab displays the ESXi hosts participating in the vSAN cluster.

- The **Health** tab displays host-level health findings.

1. Open a browser and enter the IP address of the host.

The browser redirects to the login page for the host client.

2. Enter the username and password for the host, and click **Login** .

3. In the host client navigator, click **Storage** .

4. In the main page, click the vSAN datastore to display the Monitor link in the navigator.

5. Click the tabs to view vSAN information for the host.

a) Click the **Events** tab to display the ESXi host events.
b) Click the **vSAN** tab to display basic vSAN configuration.
c) Click the **Hosts** tab to display the ESXi hosts participating in the vSAN cluster.
d) Click the **Health** tab to display host-level health findings.

6. (Optional) On the **vSAN** tab, click **Edit Settings** to correct configuration issues at the host level.

Select the values that match the configuration of your vSAN cluster, and click **Save** .


**Proactive Tests on vSAN Cluster**

You can initiate a health test on your vSAN cluster to verify that the cluster components are working as expected.

**Note:** You must not conduct the proactive test in a production environment as it creates network traffic and impacts the
vSAN workload.

Run the VM creation test to verify the vSAN cluster health. Running the test creates a virtual machine on each host in
the cluster. The test creates a VM per each ESXi host in the vSAN cluster. The VM gets deleted if the test is successful.
VM creates and and deletes tasks that you can monitor on the task console. If the VM creation and deletion tasks are
successful, assume that the cluster components are working as expected and the cluster is functional. The test results
shows the last run date and time with their status. You can also view the list of all the ESXi hosts where the test was run.

Run the Network performance test to detect and diagnose connectivity issues, and to make sure the network bandwidth
between the ESXi hosts supports the requirements of vSAN.It also allows to select Enable Network diagnostic mode
which creates a ramdisk on a host to collect and save network metrics generated during the test. The test is performed
between the ESXi hosts in the cluster. It verifies that the network bandwidth between ESXi hosts, and reports a warning if


VMware by Broadcom 1810


VMware Cloud Foundation 9.0


the bandwidth is less than 850Mbps. You can run the proactive test at a maximum speed limit of 10Gbps. In vSAN ESA,
the proactive test reports error when the result is zero bps and the Health Status displays the test results as info when the
result is a non-zero number.

To access a proactive test, select your vSAN cluster in the vSphere Client, and click the **Monitor** tab. Click **vSAN** **Proactive Tests** .

### **Managing Proactive Hardware**

vSAN Proactive Hardware Management (PHM) informs you of any dying device based on disk predictive failure events
generated by the Original Equipment Manufacturer (OEM) vendor.

Ensure that you configured a supported Hardware Support Manager (HSM) and registered to vCenter to prevent
predicative failures using PHM.

Based on this information provided by the vendor, you can take the necessary remediation. PHM resides within the vSAN
management service on the vCenter. The HSM is registered with the vCenter. PHM collects vendor hardware information
from HSM and sends it to vSAN.


**About Hardware Support Managers**

The deployment method and the management of a hardware support manager are determined by the respective OEM
vendor.

Several of the major OEM vendors develop and supply hardware support managers. For example:

- Dell - The hardware support manager that Dell provides is part of their host management solution, OpenManage
Integration for VMware vCenter (OMIVV), which you deploy as an appliance.

- HPE - The hardware support managers that HPE provides are part of their management tools, iLO Amplifier and
OneView, which you deploy as appliances.

- Lenovo - The hardware support manager that Lenovo provides is part of their server management solution, Lenovo
XClarity Integrator for VMware vCenter, which you deploy as an appliance.

You can find the full list of all VMware-certified hardware support managers in the _Broadcom Compatibility Guide_ under
[Platform & Compute section at https://compatibilityguide.broadcom.com/.](https://compatibilityguide.broadcom.com/)


**Deploying and Configuring Hardware Support Managers**

Regardless of the hardware vendor, you must deploy the hardware support manager appliance on a host with sufficient
memory, storage, and processing resources.

Typically, hardware support manager appliances are distributed as OVF or OVA templates. You can deploy them on any
host in any vCenter instance.

After you deploy the appliance, you must power on the appliance virtual machine and register the appliance as a vCenter
extension. You might need to log in to the appliance as an administrator. Each hardware support manager might register
with only one or multiple vCenter systems.

For detailed information about deploying, configuring, and managing hardware support managers, refer to the respective
[OEM-provided documentation and see Deploying Hardware Support Managers in the](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/managing-host-and-cluster-lifecycle/using-images-to-install-and-update-esxi-hosts-and-clusters/firmware-updates.html#GUID-B001135C-59AF-4CFD-9B73-94648B41D1A0-en) _Managing Host and Cluster_
_Lifecycle_ guide.


**Registering Hardware Support Manager**

You must register HSM with PHM that resides within the vSAN management service on the vCenter using the vendor
management service.


VMware by Broadcom 1811


VMware Cloud Foundation 9.0


For detailed information about registering hardware support managers, refer to the respective OEM-provided
[documentation and see Deploying Hardware Support Managers in the](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/vsphere/9-0/managing-host-and-cluster-lifecycle/using-images-to-install-and-update-esxi-hosts-and-clusters/firmware-updates.html#GUID-B001135C-59AF-4CFD-9B73-94648B41D1A0-en) _Managing Host and Cluster Lifecycle_ guide.


**Associating and Dissociating ESXi Hosts**

After registering HSM with PHM, you need to associate appropriate ESXi hosts available in the vCenter with the HSM.

This enables PHM on each host. HSM informs PHM on any change in the managed host list. PHM associates the
managed ESXi hosts available in a vSAN cluster. When a host is associated or dissociated with PHM, vCenter event gets
generated. For detailed information about associating and dissociating ESXi hosts, refer to the respective OEM-provided
documentation.


**Processing Hardware Failures**

PHM checks for HSM generated hardware failure events every 10 minutes (600 seconds).

You can customize the time interval using the vSAN configuration file.

1. Log in to vCenter console as root.

2. Open the `/usr/lib/vmware-vsan/VsanVcMgmtConfig.xml` file.

3. Set the interval value using `healthUpdatePollIntervalInSeconds` xml tag in seconds.

4. Restart the vSAN Health service using the command `service-control --restart vmware-vsan-health` .


PHM uses these events to generate alarms, which appears in the vSAN Skyline Health. For more information on the
[vSAN Skyline Health events, see the Broadcom knowledge base article 367770.](https://knowledge.broadcom.com/external/article?articleNumber=367770)
### **Monitoring vSAN Performance**

You can monitor the performance of your vSAN cluster.

Performance charts are available for clusters, ESXi hosts, physical disks, virtual machines, and virtual disks.


**About the vSAN Performance Service**

You can use vSAN performance service to monitor the performance of your vSAN environment, and investigate potential
problems.

The performance service collects and analyzes performance statistics and displays the data in a graphical format. You
can use the performance charts to manage your workload and determine the root cause of problems.

When the vSAN performance service is turned on, the cluster summary displays an overview of vSAN performance
statistics, including IOPS, throughput, and latency. You can view detailed performance statistics for the cluster, and for
each host, disk group, and disk in the vSAN cluster. You also can view performance charts for virtual machines and virtual
disks.


**Configure vSAN Performance Service**

Use the vSAN Performance Service to monitor the performance of vSAN clusters, ESXi hosts, disks, and VMs.

- All ESXi hosts in the vSAN cluster must be running ESXi 9.0 or later.

- Before you configure the vSAN Performance Service, make sure that the cluster is properly configured and has no
unresolved health problems.

**Note:**


VMware by Broadcom 1812


VMware Cloud Foundation 9.0


When you create vSAN OSA, you can optionally enable or deactivate the Performance Service. You can enable and
configure the Performance Service. When you create vSAN ESA, the Performance Service is enabled by default. You can
then configure the Performance Service.

To support the Performance Service, vSAN uses a Stats database object to collect statistical data. The Stats database is
a namespace object in the cluster's vSAN datastore.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Configure** tab.

3. Under vSAN, click **Services** .

4. (Optional for vSAN ESA cluster.) Click the Performance Service **Enable** button.

5. (Optional for vSAN ESA cluster.) In vSAN Performance Service Settings, select a storage policy for the stats database

object.

6. (Optional for vSAN ESA cluster.) Click **Enable** to enable vSAN Performance Service.

7. Click **Edit** if you want to select a different storage policy in the vSAN Performance Service Settings.

8. (Optional) Click to enable the verbose mode. This check box appears only after enabling vSAN Performance Service.

When enabled, vSAN collects and saves the additional performance metrics to a Stats DB object. If you enable the
verbose mode for more than 5 days, a warning message appears indicating that the verbose mode can be resourceintensive. Ensure that you do not enable it for a longer duration.

9. (Optional) Click to enable the network diagnostic mode. This check box appears only after enabling vSAN

Performance Service. When enabled, vSAN collects and saves the additional network performance metrics to a
RAM disk stats object. If you enable the network diagnostic mode for more than a day, a warning message appears
indicating that the network diagnostic mode can be resource-intensive. Ensure that you do not enable it for a longer
duration.

10. Click **Apply** .


**Use Saved Time Range in vSAN Cluster**

You can select saved time ranges from the time range picker in performance views.

- The vSAN performance service must be turned on.

- All ESXi hosts in the vSAN cluster must be running ESXi 9.0 or later.

You can manually save a time range with customized name. When you run a storage performance test, the selected time
range is saved automatically. You can save a time range for any of the performance views.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Monitor** tab.

3. Under vSAN, click **Performance** .

4. Select any tab, such as **Backend** .

5. Select a time range and click **Show Results** .

6. Click **Save** . The **Save Time Range** dialog opens.

7. Enter a name for the selected time range.

8. Click **Create** .

You can save the selected time range at the VM and the host level.


VMware by Broadcom 1813


VMware Cloud Foundation 9.0


**View vSAN Cluster Performance**

You can use the vSAN cluster performance charts to monitor the workload in your cluster and determine the root cause of
problems.

The vSAN performance service must be turned on before you can view performance charts.

When the performance service is turned on, the cluster summary displays an overview of vSAN performance statistics,
including vSAN IOPS, throughput, and latency. At the cluster level, you can view detailed statistical charts for virtual
machine consumption and the vSAN back end.

**Note:**

- To view iSCSI performance charts, all ESXi hosts in the vSAN cluster must be running ESXi 9.0 or later.

- To view file service performance charts, you must enable vSAN File Service.

- To view vSAN Direct performance charts, you must claim disks for vSAN Direct.

- To view PMem performance charts, you must have PMem storage attached to the ESXi hosts in the cluster.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Monitor** tab.

3. Under vSAN, select **Performance** .

4. Select **Top Contributors** .

Perform one of the following:

  - Select a time range to view the hotspot entities in the charts. You can view the top 10 hotspot entities as
aggregated metrics for the selected time range. You can view the hotspots of VMs, disk groups (vSAN OSA) or
disks (vSAN ESA), host (backend), or host (frontend). You have the option to enable separate charts.

  - Select a single timestamp to identify the VMs, disk groups (vSAN OSA) or disks (vSAN ESA), host (backend),
or host (frontend) that consume the most IOPS, have the highest I/O throughput, or I/O latency. For example,
based on the I/O latency graph of the cluster, you can select a timestamp and get the top contributors with latency
statistics. You can also select a single contributor and view the latency graph. You have the option to switch
between the combined view and table view. If you select a point in time, you can correlate the metrics between
different metric types.

5. Select **VM** .

Perform one of the following:

  - Select **Cluster level metrics** to display the aggregated performance metrics for the cluster that you selected.

  - Select **Show specific VMs** to display metrics for all the VMs selected. If you enable **Show separate chart by**
**VMs**, vSAN displays separate metrics for all the VMs selected.

Select a time range for your query. vSAN displays performance charts for clients running on the cluster, including
IOPS, throughput, latency, congestions, and outstanding I/Os. The statistics on these charts are aggregated from the
ESXi hosts within the cluster. You can also select **Real-Time** as the time range that displays real-time data that is
automatically refreshed every 30 seconds. The real-time statistics data available at cluster level is retained in the SQL
database for seven days until it gets purged.


VMware by Broadcom 1814


VMware Cloud Foundation 9.0


6. In vSAN ESA, select **Backend Cache** . Select a time range for your query. vSAN displays the performance charts for

the backend cache operations of the host, including IOPS, throughput, and latency. he statistics on these charts are
aggregated from the ESXi hosts within the cluster.

7. Select **Backend** . Select a time range for your query. vSAN displays performance charts for the cluster backend

operations, including IOPS, throughput, latency, congestions, and outstanding I/Os. The statistics on these charts are
aggregated from the ESXi hosts within the cluster.

8. Select **File Share** and choose a file. Select a time range for your query. Select **NFS performance** or **File system**

**performance** based on the protocol layer performance or file system layer performance that you want to display.
vSAN displays performance charts for vSAN file services, including IOPS, throughput, and latency.

9. Select **iSCSI** and select an iSCSI target or LUN. Select a time range for your query. vSAN displays performance charts

for iSCSI targets or LUNs, including IOPS, bandwidth, latency, and outstanding I/O.

10. (Optional) Select **I/O Insight** . For more information on I/O Insight, see Use vSAN I/O Insight.

11. Select **vSAN Direct** to display the performance data of the vSAN direct disks. Select a time range for your query.

vSAN displays performance charts for vSAN direct, including IOPS, bandwidth, latency, and outstanding I/O.

12. Select **PMEM** to display the performance data of all VMs placed on the PMem storage. Select a time range for your

query. You can also select **Real-time** as the time range that displays real time data that is automatically refreshed
every 30 seconds. PMem displays performance charts including IOPS, bandwidth, and latency. For more information
[about PMem metrics collection settings, see Broadcom knowledge base article 89100.](https://knowledge.broadcom.com/external/article?legacyId=89100)

13. Click **Refresh** or **Show Results** to update the display.


**View vSAN Host Performance**

You can use the vSAN host performance charts to monitor the workload on your ESXi hosts and determine the root cause
of problems.

The vSAN performance service must be turned on before you can view performance charts.

To view the following performance charts, ESXi hosts in the vSAN cluster must be running ESXi 9.0 or later: Physical
Adapters, VMkernal Adapters, VMkernal Adapters Aggregation, iSCSI, vSAN - Backend resync I/Os, resync IOPS, resync
throughput, Disk Group resync latency.

- You can view vSAN performance charts for ESXi hosts, disk groups, and individual storage devices. When the
performance service is turned on, the host summary displays performance statistics for each host and its attached
disks.

- At the host level, you can view detailed statistical charts for virtual machine consumption and the vSAN back end,
including IOPS, throughput, latency, and congestion.

- Additional charts are available to view the local client cache read IOPS and hit rate. At the disk group level, you can
view statistics for the disk group. At the disk level, you can view statistics for an individual storage device.

1. In the vSphere Client, navigate to the cluster and select a host.

2. Click the **Monitor** tab.

3. Under vSAN, select **Performance** .

4. Select **VM** .

  - Select **Host level metrics** to display the aggregated performance metrics for the host that you selected.

  - Select **Show specific VMs** to display metrics for all the VMs selected on the host. If you enable **Show separate**
**chart by VMs**, vSAN displays separate metrics for all the VMs selected on the host.

Select a time range for your query. vSAN displays performance charts for clients running on the host, including IOPS,
throughput, latency, congestions, and outstanding I/Os. You can also select **Real-Time** as the time range that displays


VMware by Broadcom 1815


VMware Cloud Foundation 9.0


real-time data that is automatically refreshed every 30 seconds. The real-time statistics data is retained in the SQL
database for seven days until it gets purged.

5. In vSAN ESA, select **Backend Cache** . Select a time range for your query. vSAN displays the performance charts for

the backend cache operations of the host, including the overall backend cache statistics, the overall cache miss by the
different types, cache miss by types for the different transactions, and the catch latency for the different transactions.

6. Select **Backend** . Select a time range for your query. vSAN displays performance charts for the host back-end

operations, including IOPS, throughput, latency, congestions, outstanding I/Os, and resync I/Os.

7. Perform one of the following:

  - Select **Disks**, and select a disk group. Select a time range for your query. vSAN displays performance charts for
the disk group, including front end (Guest) IOPS, throughput, and latency, as well as overhead IOPS and latency.
It also displays the read-cached hit rate, evictions, write-buffer free percentage, capacity and usage, cache disk
destage rate, congestions, outstanding I/O, outstanding I/O size, delayed I/O percentage, delayed I/O average
latency, internal queue IOPS, internal queue throughput, resync IOPS, resync throughput, and resync latency.

  - In vSAN ESA, select **Disks**, and then select a disk. Select a time range for your query. vSAN displays performance
charts for the disk, including vSAN layer IOPS, throughput, and latency. It also displays the physical or firmware
layer IOPS, throughput, and latency.

8. Select **Physical Adapters**, and select a NIC. Select a time range for your query. vSAN displays performance charts

for the physical NIC (pNIC), including throughput, packets per second, and packets loss rate.

9. Select **Host Network**, and select a VMkernel adapter, such as vmk1. Select a time range for your query. vSAN

displays performance charts for all network I/Os processed in the network adapters used by vSAN, including
throughput, packets per second, and packets loss rate.

10. Select **iSCSI** . Select a time range for your query. vSAN displays performance charts for all the iSCSI services on the

host, including IOPS, bandwidth, latency, and outstanding I/Os.

11. (Optional) Select **I/O Insight** . For more information on I/O Insight, see Use vSAN I/O Insight.

12. Select **vSAN Direct** to display the performance data of the vSAN direct disks. Select a time range for your query.

vSAN displays performance charts for vSAN direct, including IOPS, bandwidth, latency, and outstanding I/O.

13. Select **PMEM** to display the performance data of all VMs placed on the PMem storage. Select a time range for your

query. You can also select **Real-time** as the time range that displays real time data that is automatically refreshed
every 30 seconds. PMem displays the performance charts including IOPS, bandwidth, and latency. For more
[information about PMem metrics collection settings, see Broadcom knowledge base article 89100.](https://knowledge.broadcom.com/external/article?legacyId=89100)

14. Click **Refresh** or **Show Results** to update the display.


**View vSAN VM Performance**

You can use the vSAN VM performance charts to monitor the workload on your virtual machines and virtual disks.

The vSAN performance service must be turned on before you can view performance charts.

When the performance service is turned on, you can view detailed statistical charts for virtual machine performance and
virtual disk performance. VM performance statistics cannot be collected during migration between ESXi hosts, so you
might notice a gap of several minutes in the VM performance chart.

**Note:** The performance service supports only virtual SCSI controllers for virtual disks. Virtual disks using other
controllers, such as IDE, are not supported.


VMware by Broadcom 1816


VMware Cloud Foundation 9.0


1. In the vSphere Client, navigate to the cluster and select a VM.

2. Click the **Monitor** tab.

3. Under vSAN, select **Performance** .

4. Select **VM** . Select a time range for your query. vSAN displays performance charts for the VM, including IOPS,

throughput, and latency.

5. Select **Virtual Disk** . Select a time range for your query. vSAN displays performance charts for the virtual disks,

including IOPS, delayed normalized IOPS, virtual SCSI IOPS, virtual SCSI throughput, and virtual SCSI latency. The
virtual SCSI latency performance charts display a highlighted area due to the IOPS limit enforcement.

6. Click **I/O Insight** . For more information on I/O Insight, see Use vSAN I/O Insight.

7. Click **Refresh** or **Show Results** to update the display.


**Use vSAN I/O Insight**

I/O Insight allows you to select and view I/O performance metrics of virtual machines in a vSAN cluster.

By understanding the I/O characteristics of VMs, you can ensure better capacity planning and performance tuning. The
vSAN performance might be impacted when you enable I/O Insight.

1. In the vSphere Client, navigate to the cluster or host.

You can also access I/O Insight from the VM. Select the VM and navigate to **Monitor**  - **vSAN**  - **Performance**  - **IO**
**Insight** .

2. Click the **Monitor** tab.

3. Under **vSAN**, select **Performance** .

4. Select the **I/O Insight** tab and click **New Instance** .

5. Select the required ESXi hosts or VMs that you want to monitor. You can also search for VMs.

6. Click **Next** . Based on the host or VM selected, the name is automatically populated.

7. Select a duration in minutes or hours.

8. Click **Next** and review the instance information.

9. Click **Finish** .

I/O Insight instance monitors the selected VMs for the specified duration. However, you can stop an instance before
completion of the duration that you specified.

**Note:**

VMs monitored by I/O Insight must not be vMotioned. vMotion stops the VMs from being monitored and will result in an
unsuccessful trace preventing vSAN I/O insight monitoring from successful completion. DRS analyzes resource usage
and availability in a cluster and decides when and where to move VMs to balance the load and optimize resource
allocation.


vSAN displays performance charts for the VMs in the cluster, including IOPS, throughput, I/O size distribution, I/O latency
distribution, and so on.

You can view metrics for the I/O Insight instance that you created.


VMware by Broadcom 1817


VMware Cloud Foundation 9.0


**View vSAN I/O Insight Metrics**


I/O Insight performance metrics chart displays the metrics at the virtual disk level.

When I/O Insight is running, vSAN collects and displays the metrics for selected VMs, for a set duration. You can view the
performance metrics for up to 90 days. The I/O Insight instances are automatically deleted after this period.

1. In the vSphere Client, navigate to the cluster or host.

You can also access I/O Insight from the VM. Select the VM and navigate to **Monitor**  - **vSAN**  - **Performance**  **Virtual Disks** .

2. Click the **Monitor** tab.

3. Under **vSAN**, select **Performance** .

4. Select the **I/O Insight** tab. You can organize the instances based on time or ESXi hosts.

5.

To view the metrics of an instance, click and click **View Metrics** . You can optionally stop a running instance
before completing the specified duration.
You can rerun an instance, and rename or delete the existing instances.


**Use vSAN I/O Trip Analyzer**

You can use vSAN I/O trip analyzer to diagnose the virtual machine I/O latency issues.

The vSAN performance service must be enabled before you can run the I/O trip analyzer and view the test results.

vSAN latency issues can be caused by outstanding I/Os, network hardware issues, network congestions, or disk
slowness. The I/O trip analyzer allows you to get the breakdown of the latencies at each layer of the vSAN stack. The
topology diagram shows only the ESXi hosts with VM I/O traffic.

**Note:**

All the ESXi hosts and vCenter in the vSAN cluster must be running 9.0 or later.

Using the I/O trip analyzer scheduler, you can set the recurrence for I/O trip analyzer diagnostic operations. You can either
set a one time occurrence or set the recurrence to later. On reaching the recurrence time, the scheduler automatically
collects the results. You can view the results collected within 30 days.

**Note:** The I/O trip analyzer supports stretched cluster and multiple VMs (maximum 8 VMs and 64 VMDKs) in one
diagnostic run for a single cluster.

1. In the vSphere Client, navigate to the cluster.

2. Select a VM.

3. Click the **Monitor** tab.

4. Under vSAN, select **I/O Trip Analyzer** .

5. Click **Run New Test** .

6. In the Run VM I/O Trip Analyzer Test, select the duration of the test.

7. (Optional) Select **Scheduling** to schedule the test for a later time. You can either select **Start now** or enter a time

based on your requirement in the **Custom time** field. Select the repeat options and click **Schedule** .

**Note:**

You can schedule only a single I/O trip analyzer per cluster. You can schedule another I/O trip analyzer after deleting
the current scheduler. To delete a scheduler, click **Schedules**   - **Delete** . You can also modify a schedule that you
created. Click **Schedules**   - **Edit** . You can repeat a schedule that you have defined.


VMware by Broadcom 1818


VMware Cloud Foundation 9.0


8. Click **Finish** . The trip analyzer test data is persisted and is available only for 30 days.

**Note:** vSAN does not support I/O trip analyzer for virtual disks in a remote vSAN datastore.

9. Click **View Result** to view the visualized I/O topology.

10. From the Virtual Disks drop-down, select the disk for which you want to view the I/O topology. You can also view the

performance details of the network and the disk groups. Click the edge points of the topology to view the latency
details.
Click the edge points of the topology to view the latency details. If there is a latency issue, click the red icon to focus
on that area.

11. Click **Export Data** to generate a zip file that includes the results graph PNG images and raw data in CSV file format.


**View vSAN Performance Metrics for Support Cases**

Use the vSAN cluster performance metrics to monitor the performance of your cluster and determine the root cause of the
performance issues.

The vSAN performance service must be turned on before you can view performance charts.

You can use the vSAN Obfuscation Map to identify the obfuscated data sent to VMware. For more information on
obfuscation map, see View vSAN Obfuscation Map.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Monitor** tab.

3. Under vSAN, select **Support** - **Performance For Support** .

4. Select a performance dashboard from the drop-down menu.

5. Select ESXi hosts, disks, or NICs from the drop-down menu.

6. Select a time range for your query.

The default time range is the most recent hour. You can increase the range to include the last 24 hours, or define a
custom time range within the last 90 days. If you used the HCIbench tool to run performance benchmark tests on the
vSAN cluster, the time ranges of those tests appear in the drop-down menu.

7. Click **Show Results** .

vSAN displays performance charts for selected entities, such as IOPS, throughput, latency, congestions, and
outstanding I/Os.


**Using vSAN Performance Diagnostics**

You can use vSAN performance diagnostics to improve the performance of your vSAN OSA cluster, and resolve
performance issues.

- The vSAN performance service must be turned on.

- vCenter requires Internet access to download ISO images and patches and to send data to VMware to analyze vSAN
performance data.

- You must participate in the Customer Experience Improvement Program (CEIP).

The vSAN performance diagnostics tool analyzes previously run benchmarks gathered from the vSAN performance
service. It can detect issues, suggest remediation steps, and provide supporting performance graphs for further insight.

The vSAN performance service provides the data used to analyze vSAN performance diagnostics. vSAN uses CEIP to
send data to VMware for analysis.

**Note:**


VMware by Broadcom 1819


VMware Cloud Foundation 9.0


vSAN ESA cluster does not support vSAN performance diagnostics. Do not use vSAN performance diagnostics for
general evaluation of performance on a production vSAN cluster.

1. In the vSphere Client, navigate to the cluster.

2. Click the **Monitor** tab.

3. Under vSAN, select **Performance Diagnostics** .

4. Select a benchmark goal from the drop-down menu.

You can select a goal based on the performance improvement that you want to achieve, such as maximum IOPS,
maximum throughput, or minimum latency.

5. Select a time range for your query.

The default time range is the most recent hour. You can increase the range to include the last 24 hours, or define a
custom time range within the last 90 days. If you used the HCIbench tool to run performance benchmark tests on the
vSAN cluster, the time ranges of those tests appear in the drop-down menu.

6. Click **Show Results** .


When you click **Show Results**, vSAN transmits performance data to the vSphere backend analytics server. After
analyzing the data, the vSAN performance diagnostics tool displays a list of issues that might have affected the
benchmark performance for the chosen goal.

You can click to expand each issue to view more details about each issue, such as a list of affected items. You also can
click **See More** or **Ask VMware** to display a Knowledge Base article that describes recommendations to address the issue
and achieve your performance goal.


**View vSAN Obfuscation Map**

You can use the vSAN Obfuscation Map to identify the obfuscated data sent to VMware.

vSAN Obfuscation Map provides mapping of the obfuscated data sent to VMware as part of Customer Experience
Improvement Program (CEIP) to facilitate communication during the Support Request process between vSAN user and
VMware Global Support. Use notepad or any text editor to view the obfuscation map. For more information on obfuscation
map, see the Broadcom knowledge base article `[51120](https://knowledge.broadcom.com/external/article?legacyId=51120)` .

1. In the vSphere Client, navigate to the cluster.
2. Click the **Monitor** tab.
3. Under vSAN, select **Support** .
4. Click **Obfuscation** .
5. Click **View Online** or **Download Obfuscation Map** to view or download the vSphere entities.

### **Handling Failures and Troubleshooting vSAN**

If you encounter problems when using vSAN, you can use troubleshooting topics.

The topics help you understand the problem and offer you a workaround, when it is available.


**Uploading a vSAN Support Bundle**

You can upload a vSAN support bundle so VMware service personnel can analyze the diagnostic information.

Broadcom Technical Support routinely requests diagnostic information from your vSAN cluster when a support request
is addressed. The support bundle is an archive that contains diagnostic information related to the environment, such as
product specific logs, configuration files, and so on.


VMware by Broadcom 1820


VMware Cloud Foundation 9.0


The log files, collected and packaged into a zip file, include the following:

- vCenter support bundle

- Host support bundle

The host support bundle in the cluster includes the following:
```
 ["Userworld:HostAgent", "Userworld:FDM",
 "System:VMKernel", "System:ntp", "Storage:base", "Network:tcpip",
 "Network:dvs", "Network:base", "Logs:System", "Storage:VSANMinimal",
 "Storage:VSANHealth", "System:BaseMinmal", "Storage:VSANTraces"]
```

vSAN performs an automated upload of the support bundle, and does not allow you to review, obfuscate, or otherwise edit
the contents of your support data prior to it being sent to VMware. vSAN connects to the FTP port 21 or HTTPS port 443
of the target server with the domain name _vmware.com_, to automatically upload the support bundle.

**Note:** Data collected in the support bundle may be considered sensitive. If your support data contains regulated data,
such as personal, health care, or financial data, you may want to avoid uploading the support bundle.

1. Right-click the vSAN cluster in the vSphere Client.

2. Choose menu **vSAN > Upload support bundle...**

3. Enter your service request ID and a description of your issue.

4. Click **Upload** .


**Using Esxcli Commands with vSAN**

Use Esxcli commands to obtain information about vSAN OSA or vSAN ESA and to troubleshoot your vSAN environment.

The following commands are available:

|Command|Description|
|---|---|
|`esxcli vsan network list`|Verify which VMkernel adapters are used for vSAN<br>communication.|
|`esxcli vsan storage list`|List storage disks claimed by vSAN.|
|<br>`esxcli vsan storagepool list`|List storage pool claimed by vSAN ESA. This command is<br>applicable only for vSAN ESA cluster.|
|`esxcli vsan cluster get`|Get vSAN cluster information.|
|<br>`esxcli vsan health`|Get vSAN cluster health status.|
|<br>`esxcli vsan debug`|Get vSAN cluster debug information.|



The `esxcli vsan debug` commands can help you debug and troubleshoot the vSAN cluster, especially when vCenter is
not available.

Use: `esxcli vsan debug {cmd} [cmd options]`

Debug commands:

|Command|Description|
|---|---|
|`esxcli vsan debug disk`|Debug vSAN physical disks.|
|<br>`esxcli vsan debug object`|Debug vSAN objects.|
|<br>`esxcli vsan debug resync`|Debug vSAN resyncing objects.|



VMware by Broadcom 1821


VMware Cloud Foundation 9.0

|Command|Description|
|---|---|
|`esxcli vsan debug controller`|Debug vSAN disk controllers.|
|<br>`esxcli vsan debug limit`|Debug vSAN limits.|
|<br>`esxcli vsan debug vmdk`|Debug vSAN VMDKs.|



Example `esxcli vsan debug` commands:
```
 esxcli vsan debug disk summary get
 Overall Health: green
 Component Metadata Health: green
 Memory Pools (heaps): green
 Memory Pools (slabs): green
 esxcli vsan debug disk list
 UUID: 52e1d1fa-af0e-0c6c-f219-e5e1d224b469
 Name: mpx.vmhba1:C0:T1:L0
 SSD: False
 Overall Health: green
 Congestion Health:
 State: green
 Congestion Value: 0
 Congestion Area: none
 In Cmmds: true
 In Vsi: true
 Metadata Health: green
 Operational Health: green
 Space Health:
 State: green
 Capacity: 107365793792 bytes
 Used: 1434451968 bytes
 Reserved: 150994944 bytes
 esxcli vsan debug object health summary get
 Health Status                   Number Of Objects
 ------------------------------------------------ ---------------- reduced-availability-with-no-rebuild-delay-timer         0
 reduced-availability-with-active-rebuild             0
 inaccessible                           0
 data-move                             0
 healthy                              1
 nonavailability-related-incompliance               0
 nonavailability-related-reconfig                 0
 reduced-availability-with-no-rebuild               0
 esxcli vsan debug object list
 Object UUID: 47cbdc58-e01c-9e33-dada-020010d5dfa3
 Version: 5
 Health: healthy
 Owner:
 Policy:
 stripeWidth: 1
 CSN: 1
 spbmProfileName: vSAN Default Storage Policy
 spbmProfileId: aa6d5a82-1c88-45da-85d3-3d74b91a5bad
 forceProvisioning: 0

```

VMware by Broadcom 1822


VMware Cloud Foundation 9.0

```
 cacheReservation: 0
 proportionalCapacity: [0, 100]
 spbmProfileGenerationNumber: 0
 hostFailuresToTolerate: 1

 Configuration:
 RAID_1
 Component: 47cbdc58-6928-333f-0c51-020010d5dfa3
 Component State: ACTIVE, Address Space(B): 273804165120 (255.00GB),
 Disk UUID: 52e95956-42cf-4d30-9cbe-763c616614d5, Disk Name: mpx.vmhba1..
 Votes: 1, Capacity Used(B): 373293056 (0.35GB),
 Physical Capacity Used(B): 369098752 (0.34GB), Host Name: sc-rdops...
 Component: 47cbdc58-eebf-363f-cf2b-020010d5dfa3
 Component State: ACTIVE, Address Space(B): 273804165120 (255.00GB),
 Disk UUID: 52d11301-1720-9901-eb0a-157d68b3e4fc, Disk Name: mpx.vmh...
 Votes: 1, Capacity Used(B): 373293056 (0.35GB),
 Physical Capacity Used(B): 369098752 (0.34GB), Host Name: sc-rdops-vm..
 Witness: 47cbdc58-21d2-383f-e45a-020010d5dfa3
 Component State: ACTIVE, Address Space(B): 0 (0.00GB),
 Disk UUID: 52bfd405-160b-96ba-cf42-09da8c2d7023, Disk Name: mpx.vmh...
 Votes: 1, Capacity Used(B): 12582912 (0.01GB),
 Physical Capacity Used(B): 4194304 (0.00GB), Host Name: sc-rdops-vm...

 Type: vmnamespace
 Path: /vmfs/volumes/vsan:52134fafd48ad6d6-bf03cb6af0f21b8d/New Virtual Machine
 Group UUID: 00000000-0000-0000-0000-000000000000
 Directory Name: New Virtual Machine
 esxcli vsan debug controller list
 Device Name: vmhba1
 Device Display Name: LSI Logic/Symbios Logic 53c1030 PCI-X Fusion-MPT Dual Ult..
 Used By VSAN: true
 PCI ID: 1000/0030/15ad/1976
 Driver Name: mptspi
 Driver Version: 4.23.01.00-10vmw
 Max Supported Queue Depth: 127
 esxcli vsan debug limit get
 Component Limit Health: green
 Max Components: 750
 Free Components: 748
 Disk Free Space Health: green
 Lowest Free Disk Space: 99 %
 Used Disk Space: 1807745024 bytes
 Used Disk Space (GB): 1.68 GB
 Total Disk Space: 107365793792 bytes
 Total Disk Space (GB): 99.99 GB
 Read Cache Free Reservation Health: green
 Reserved Read Cache Size: 0 bytes
 Reserved Read Cache Size (GB): 0.00 GB
 Total Read Cache Size: 0 bytes
 Total Read Cache Size (GB): 0.00 GB
 esxcli vsan debug vmdk list
 Object: 50cbdc58-506f-c4c2-0bde-020010d5dfa3

```

VMware by Broadcom 1823


VMware Cloud Foundation 9.0

```
 Health: healthy
 Type: vdisk
 Path: /vmfs/volumes/vsan:52134fafd48ad6d6-bf03cb6af0f21b8d/47cbdc58-e01c-9e33 dada-020010d5dfa3/New Virtual Machine.vmdk
 Directory Name: N/A
 esxcli vsan debug resync list
 Object      Component       Bytes Left To Resync GB Left To Resync
 ---------------- --------------------- -------------------- ---------------- 31cfdc58-e68d... Component:23d1dc58...       536870912 0.50
 31cfdc58-e68d... Component:23d1dc58...      1073741824 1.00
 31cfdc58-e68d... Component:23d1dc58...      1073741824 1.00

```

**Using vsantop Command-Line Tool**

Use the command-line tool - vsantop - that runs on ESXi hosts to view the real time vSAN performance metrics.

You can use this tool to monitor vSAN performance. To display the different performance views and metrics in vsantop,
enter the following commands:

|Command|Description|
|---|---|
|`^L`|Redraw screen|
|`Space`|Update display|
|`h` or`?`|Help; show this text|
|`q`|Quit|
|`f/F`|Add or remove fields|
|`o/O`|Change the order of displayed fields|
|`s`|Set the delay in seconds between updates|
|`#`|Set the number of instances to display|
|`E`|Change the selected entity type|
|`L`|Change the length of the field|
|`l`|Limit display to specific node id|
|`.`|Sort by column, same number twice to change sort order|



**vSAN Configuration on an ESXi Host Might Fail**

In certain circumstances, the task of configuring vSAN on a particular host might fail.

An ESXi host that joins a vSAN cluster fails to have vSAN configured.

If a host does not meet hardware requirements or experiences other problems, vSAN might fail to configure the host. For
example, insufficient memory on the host might prevent vSAN from being configured.


VMware by Broadcom 1824


VMware Cloud Foundation 9.0


1. Place the host that causes the failure in Maintenance Mode.

2. Move the host out of the vSAN cluster.

3. Resolve the problem that prevents the host to have vSAN configured.

4. Move the host back into the vSAN cluster.

5. Exit Maintenance Mode.


**Not Compliant Virtual Machine Objects Do Not Become Compliant Instantly**

When you use the **Check Compliance** button, a virtual machine object does not change its status from Not Compliant to
Compliant even though vSAN resources have become available and satisfy the virtual machine profile.

When you use force provisioning, you can provision a virtual machine object even when the policy specified in the virtual
machine profile cannot be satisfied with the resources available in the vSAN cluster. The object is created, but remains in
the non-compliant status.

vSAN is expected to bring the object into compliance when storage resources in the cluster become available, for
example, when you add an ESXi host. However, the object's status does not change to compliant immediately after you
add resources.

This occurs because vSAN regulates the pace of the reconfiguration to avoid overloading the system. The amount of time
it takes for compliance to be achieved depends on the number of objects in the cluster, the I/O load on the cluster and the
size of the object in question. In most cases, compliance is achieved within a reasonable time.


**vSAN Cluster Configuration Issues**

After you change the vSAN configuration, vCenter performs validation checks for vSAN configuration.

Error messages indicate that vCenter has detected a problem with vSAN configuration.

**Note:** Validation checks are also performed as a part of a host synchronization process.

If vCenter detects any configuration problems, it displays error messages. Use the following methods to fix vSAN
configuration problems.


**Table 851: vSAN Configuration Errors and Solutions**












|vSAN Configuration Error|Solution|
|---|---|
|Host with the vSAN service enabled is not in the vCenter cluster|Add the host to the vSAN cluster.<br>1.<br>Right-click the host, and select**Move To**.<br>2.<br>Select the vSAN cluster and click**OK**.|
|Host is in a vSAN enabled cluster but does not have vSAN service<br>enabled|Verify whether vSAN network is properly configured and enabled<br>on the host. SeeConfigure a vSAN Cluster for Using the vSphere<br>Client.|
|vSAN network is not configured|Configure vSAN network. SeeConfiguring the vSAN Network.|
|Host cannot communicate with all other nodes in the vSAN<br>enabled cluster|Might be caused by network isolation.|
|Found another host participating in the vSAN service which is not<br>a member of this host's vCenter cluster.|Make sure that the vSAN cluster configuration is correct and all<br>ESXi hosts are in the same vCenter inventory.|



VMware by Broadcom 1825


VMware Cloud Foundation 9.0


**Handling Failures in vSAN**

vSAN handles failures of the storage devices, ESXi hosts and network in the cluster according to the severity of the
failure.

You can diagnose problems in vSAN by observing the performance of the vSAN datastore and network.


**Failure Handling in vSAN**


vSAN implements mechanisms for indicating failures and rebuilding unavailable data for data protection.

**Failure States of vSAN Components**
In vSAN, components that have failed can be in absent or degraded state.

According to the component state, vSAN uses different approaches for recovering virtual machine data. vSAN also
provides alerts about the type of component failure. See Using the VMkernel Observations for Creating vSAN Alarms and
Using the vSAN Default Alarms.

vSAN supports two types of failure states for components:


**Table 852: Failure States of Components in vSAN**








|Component<br>Failure State|Description|Recovery|Cause|
|---|---|---|---|
|Degraded|A component is in degraded state<br>if vSAN detects a permanent<br>component failure and assumes that<br>the component is not going to recover<br>to working state.|vSAN starts rebuilding the affected<br>components immediately if there<br>are adequate resources in the<br>cluster.|•<br>Failure of a flash caching device<br>•<br>Magnetic or flash capacity<br>device failure<br>•<br>Storage controller failure<br>|
|Absent|A component is in absent state if<br>vSAN detects a temporary component<br>failure where the component might<br>recover and restore its working state.|vSAN starts rebuilding the affected<br>components immediately if there<br>are adequate resources in the<br>cluster if they are not available<br>within a certain time interval. By<br>default, vSAN starts rebuilding<br>absent components after 60<br>minutes.|•<br>Lost network connectivity<br>•<br>Failure of a physical network<br>adapter<br>•<br>ESXi host failure<br>•<br>Unplugged flash caching device<br>•<br>Unplugged magnetic disk or<br>flash capacity device|



Examine the Failure State of a Component
You can determine whether a component is in the absent or degraded failure state.

If a failure occurs in the cluster, vSAN marks the components for an object as absent or degraded based on the failure
severity.

1. In the vSphere Client, navigate to the cluster.

2. On the **Monitor** tab, click **vSAN** and select **Virtual Objects** .

The home directories and virtual disks of the virtual machines in the cluster appear.

3. Select the check box on one of the virtual objects and click **View Placement Details** to open the Physical Placement

dialog. You can view device information, such as name, identifier or UUID, number of devices used for each virtual
machine, and how they are mirrored across ESXi hosts.

**Object States That Indicate Problems in vSAN**
Examine the compliance status and the operational state of a virtual machine object to find how a failure in the cluster
affects the virtual machine.


VMware by Broadcom 1826


VMware Cloud Foundation 9.0


**Table 853: Object State**

|Object State Type|Description|
|---|---|
|Compliance Status|The compliance status of a virtual machine object indicates whether it meets the<br>requirements of the assigned VM storage policy.|
|Operational State|The operational state of an object can be healthy or unhealthy. It indicates the type<br>and number of failures in the cluster.<br>An object is healthy if an intact replica is available and more than 50 percent of the<br>object's votes are still available.<br>An object is unhealthy if an entire replica is not available or less than 50 percent of<br>the object's votes are unavailable. For example, an object might become unhealthy<br>if a network failure occurs in the cluster and a host becomes isolated.|



To determine the overall influence of a failure on a virtual machine, examine the compliance status and the operational
state. If the operational state remains healthy although the object is noncompliant, the virtual machine can continue using
the vSAN datastore. If the operational state is unhealthy, the virtual machine cannot use the datastore.


Examine the Health of an Object in vSAN
Use the vSphere Client to examine whether a virtual object is healthy.

A virtual machine is considered as healthy when a replica of the VM object and more than 50 percent of the votes for an
object are available.

1. In the vSphere Client, navigate to the cluster.

2. On the **Monitor** tab, click **vSAN** and select **Virtual Objects** .

The home directories and virtual disks of the virtual machines in the cluster appear.

3. Select an object type in the **Affected inventory objects** area at the top of the page to display information about each

object, such as object state, storage policy, and vSAN UUID.
If the inventory object is Unhealthy, the vSphere Client indicates the reason for the unhealthy state in brackets.

Examine the Compliance of a Virtual Machine in vSAN
Use the vSphere Client to examine whether a virtual machine object is compliant with the assigned VM storage policy.

1. Examine the compliance status of a virtual machine.

a) In the vSphere Client, navigate to the virtual machine in the cluster.
b) On the **Summary** tab, examine the value of the VM Storage Policy Compliance property under VM Storage

Policies.

2. Examine the compliance status of the objects of the virtual machine.



a) In the vSphere Client, navigate to the virtual machine in the cluster.
b) On the **Monitor** tab, click **vSAN** and select **Virtual Objects** .
c) Select an object type in the **Affected inventory objects** area at the top of the page to display information about



each object, such as object state, storage policy, and vSAN UUID.
d) Select the check box on one of the virtual objects and click **View Placement Details** to open the Physical



Placement dialog. You can view device information, such as name, identifier or UUID, number of devices used for
each virtual machine, and how they are mirrored across ESXi hosts.
e) On the Physical Placement dialog, check the **Group components by host placement** check box to organize the



objects by host and by disk.



**Accessibility of Virtual Machines Upon a Failure in vSAN**
If a virtual machine uses vSAN storage, its storage accessibility might change according to the type of failure in the vSAN
cluster.


VMware by Broadcom 1827


VMware Cloud Foundation 9.0


Changes in the accessibility occur when the cluster experiences more failures than the policy for a virtual machine object
tolerates.

As a result from a failure in the vSAN cluster, a virtual machine object might become inaccessible. An object is
inaccessible if a full replica of the object is not available because the failure affects all replicas, or when less than 50
percent of the object's votes are available.

According to the type of object that is inaccessible, virtual machines behave in the following ways:


**Table 854: Inaccessibility of Virtual Machine Objects**








|Object Type|Virtual Machine State|Virtual Machine Symptoms|
|---|---|---|
|VM Home Namespace|•<br>Inaccessible<br>•<br>Orphaned if vCenter or the ESXi host cannot access<br>the`.vmx` file of the virtual machine.|The virtual machine process might crash<br>and the virtual machine might be powered<br>off.|
|VMDK|Inaccessible|The virtual machine remains powered on<br>but any I/O operations on the VMDK will<br>fail. Depending on the guest operating<br>system, the guest ends the operation<br>and triggers a event indicating a disk I/O<br>timeout.|



Virtual machine inaccessibility is not a permanent state. After the underlying issue is resolved, and a full replica and more
than 50 percent of the object's votes are restored, the virtual machine automatically becomes accessible again.


**Storage Device is Failing in vSAN Cluster**
vSAN monitors the performance of each storage device and proactively isolates unhealthy devices.

It detects gradual failure of a storage device and isolates the device before congestion builds up within the affected host
and the entire vSAN cluster.

If a disk experiences sustained high latencies or congestion, vSAN considers the device as a dying disk, and evacuates
data from the disk. vSAN handles the dying disk by evacuating or rebuilding data. No user action is required, unless the
cluster lacks resources or has inaccessible objects.


**Component Failure State and Accessibility**

The vSAN components that reside on the magnetic disk or flash capacity device are marked as absent.


**Behavior of vSAN**

vSAN responds to the storage device failure in the following ways.

|Parameter|Behavior|
|---|---|
|Alarms|An alarm is generated from each host whenever an unhealthy<br>device is diagnosed. A warning is issued whenever a disk is<br>suspected of being unhealthy.|
|Health finding|The**Disk operation** health finding issues a warning for the dying<br>disk.|
|Health status|On the Disk Management page, the health status of the dying disk<br>is listed as**Unhealthy**. When vSAN completes evacuation of data,<br>the health status is listed as**DyingDiskEmpty**.|



VMware by Broadcom 1828


VMware Cloud Foundation 9.0

|Parameter|Behavior|
|---|---|
|Rebuilding data|vSAN examines whether the ESXi hosts and the capacity devices<br>can satisfy the requirements for space and placement rules for<br>the objects on the failed device or disk group. If such a host<br>with capacity is available, vSAN starts the recovery process<br>immediately because the components are marked as degraded.<br>If resources are available, vSAN automatically reprotects the data.|



If vSAN detects a disk with a permanent error, it makes a limited number of attempts to revive the disk by unmounting and
mounting it.


**Capacity Device Not Accessible in vSAN Cluster**
When a magnetic disk or flash capacity device fails, vSAN evaluates the accessibility of the objects on the device.

vSAN rebuilds them on another host if space is available and the **Primary level of failures to tolerate** is set to 1 or more.


**Component Failure State and Accessibility**

The vSAN components that reside on the magnetic disk or flash capacity device are marked as degraded.


**Behavior of vSAN**

vSAN responds to the capacity device failure in the following ways.

|Parameter|Behavior|
|---|---|
|Level of failures to tolerate|If the**Level of failures to tolerate** in the VM storage policy is<br>equal to or greater than 1, the virtual machine objects are still<br>accessible from another ESXi host in the cluster. If resources are<br>available, vSAN starts an automatic reprotection.<br>If the**Level of failures to tolerate** is set to 0, a virtual machine<br>object is inaccessible if one of the object's components resides on<br>the failed capacity device.<br>Restore the virtual machine from a backup.|
|I/O operations on the capacity device|When a vSAN object experiences a failure or a failed component,<br>I/O operations stop between 5-7 seconds until it revaluates if the<br>object is available.<br>If vSAN determines that the object is available, all running<br>operations are resumed.|
|Rebuilding data|vSAN examines whether the ESXi hosts and the capacity devices<br>can satisfy the requirements for space and placement rules for<br>the objects on the failed device or disk group. If such a host<br>with capacity is available, vSAN starts the recovery process<br>immediately because the components are marked as degraded.<br>If resources are available, an automatic reprotect will occur.|



**Storage Pool Device Is Not Accessible in vSAN ESA Cluster**
When a storage pool device fails, vSAN evaluates the accessibility of the objects on the device.

vSAN rebuilds them on another host if space is available and the Primary level of failures to tolerate is set to 1 or more.


**Component Failure State and Accessibility**

vSAN responds to the storage pool device failure in the following ways.


VMware by Broadcom 1829


VMware Cloud Foundation 9.0

|Parameter|Behavior|
|---|---|
|Level of failures to tolerate|If the**Level of failures to tolerate** in the VM storage policy is<br>equal to or greater than 1, the virtual machine objects are still<br>accessible from another ESXi host in the cluster. If resources are<br>available, vSAN starts an automatic reprotection.<br>If the**Level of failures to tolerate** is set to 0, a virtual machine<br>object is inaccessible if one of the object's components resides on<br>the failed capacity device.<br>Restore the virtual machine from a backup.|
|I/O operations on the capacity device|When a vSAN object experiences a failure or a failed component,<br>I/O operations stop between 5-7 seconds until it revaluates if the<br>object is available.<br>If vSAN determines that the object is available, all running<br>operations are resumed.|
|Rebuilding data|vSAN examines whether the ESXi hosts and the capacity devices<br>can satisfy the requirements for space and placement rules for<br>the objects on the failed device or disk group. If such a host<br>with capacity is available, vSAN starts the recovery process<br>immediately because the components are marked as degraded.<br>If resources are available, an automatic reprotect will occur.|



**A Caching Device Is Not Accessible in a vSAN Cluster**
When a flash caching device fails, vSAN evaluates the accessibility of the objects on the disk group that contains the
cache device.

vSAN rebuilds them on another host if possible and the **Primary level of failures to tolerate** is set to 1 or more.


**Component Failure State and Accessibility**

Both cache device and capacity devices that reside in the disk group, for example, magnetic disks, are marked as
degraded. vSAN interprets the failure of a single flash caching device as a failure of the entire disk group.


**Behavior of vSAN**

vSAN responds to the failure of a flash caching device in the following way:

|Parameter|Behavior|
|---|---|
|Level of failures to tolerate|If the**Level of failures to tolerate** in the VM storage policy is<br>equal to or greater than 1, the virtual machine objects are still<br>accessible from another ESXi host in the cluster. If resources are<br>available, vSAN starts an automatic reprotection.<br>If the**Level of failures to tolerate** is set to 0, a virtual machine<br>object is inaccessible if one of the object's components resides on<br>the failed capacity device.|
|I/O operations on the disk group|When a vSAN object experiences a failure or a failed component,<br>I/O operations stop between 5-7 seconds until it revaluates if the<br>object is available.<br>If vSAN determines that the object is available, all running<br>operations are resumed.|



VMware by Broadcom 1830


VMware Cloud Foundation 9.0

|Parameter|Behavior|
|---|---|
|Rebuilding data|vSAN examines whether the ESXi hosts and the capacity devices<br>can satisfy the requirements for space and placement rules for<br>the objects on the failed device or disk group. If such a host<br>with capacity is available, vSAN starts the recovery process<br>immediately because the components are marked as degraded.<br>If resources are available, an automatic reprotect will occur.|



**A Host is Not Responding in vSAN Cluster**
If a host stops responding due to failure or reboot of the host, vSAN waits for the host to recover and rebuilds the
components elsewhere in the cluster.


**Component Failure State and Accessibility**

The vSAN components that reside on the host are marked as absent.


**Behavior of vSAN**

vSAN responds to the host failure in the following way:

|Parameter|Behavior|
|---|---|
|Level of failures to tolerate|If the**Level of failures to tolerate** in the VM storage policy is<br>equal to or greater than 1, the virtual machine objects are still<br>accessible from another ESXi host in the cluster. If resources are<br>available, vSAN starts an automatic reprotection.<br>If the**Level of failures to tolerate** is set to 0, a virtual machine<br>object is inaccessible if one of the object's components resides on<br>the failed capacity device.|
|I/O operations on the host|When a vSAN object experiences a failure or a failed component,<br>I/O operations stop between 5-7 seconds until it revaluates if the<br>object is available.<br>If vSAN determines that the object is available, all running<br>operations are resumed.|
|Rebuilding data|vSAN examines whether the ESXi hosts and the capacity devices<br>can satisfy the requirements for space and placement rules for<br>the objects on the failed device or disk group. If such a host<br>with capacity is available, vSAN starts the recovery process<br>immediately because the components are marked as degraded.<br>If resources are available, an automatic reprotect will occur.|



**Network Connectivity is Lost in vSAN Cluster**
When the connectivity between the ESXi hosts in the cluster is lost, vSAN determines the active partition.

vSAN rebuilds the components from the isolated partition on the active partition if the connectivity is not restored.


**Component Failure State and Accessibility**

vSAN determines the partition where more than 50 percent of the votes of an object are available. The components on the
isolated hosts are marked as absent.


**Behavior of vSAN**

vSAN responds to a network failure in the following way:


VMware by Broadcom 1831


VMware Cloud Foundation 9.0

|Parameter|Behavior|
|---|---|
|Level of failures to tolerate|If the**Level of failures to tolerate** in the VM storage policy is<br>equal to or greater than 1, the virtual machine objects are still<br>accessible from another ESXi host in the cluster. If resources are<br>available, vSAN starts an automatic reprotection.<br>If the**Level of failures to tolerate** is set to 0, a virtual machine<br>object is inaccessible if one of the object's components resides on<br>the failed capacity device.|
|I/O operations on the isolated hosts|When a vSAN object experiences a failure or a failed component,<br>I/O operations stop between 5-7 seconds until it revaluates if the<br>object is available.<br>If vSAN determines that the object is available, all running<br>operations are resumed.|
|Rebuilding data|If the host rejoins the cluster with 60 minutes, vSAN synchronizes<br>the components on the host.<br>If the host does not rejoin the cluster within 60 minutes, vSAN<br>examines whether some of the other ESXi hosts in the cluster can<br>satisfy the requirements for cache, space, and placement rules<br>for the objects on the inaccessible host. If such a host is available,<br>vSAN starts the recovery process.<br>If the host rejoins the cluster after 60 minutes and recovery has<br>started, vSAN evaluates whether to continue the recovery or stop<br>it and resynchronize the original components.|



**A Storage Controller Fails in vSAN Cluster**
When a storage controller fails, vSAN evaluates the accessibility of the objects on the disk groups that are attached to the
controller.

vSAN rebuilds them on another host.


**Symptoms**

If a host contains a single storage controller and multiple disk groups, and all devices in all disk groups are failed, then you
might assume that a failure in the common storage controller is the root cause. Examine the VMkernel log messages to
determine the nature of the fault.


**Component Failure State and Accessibility**

When a storage controller fails, the components on the flash caching devices and capacity devices in all disk groups that
are connected to the controller are marked as degraded.

If a host contains multiple controllers, and only the devices that are attached to an individual controller are inaccessible,
then you might assume that this controller has failed.


**Behavior of vSAN**

vSAN responds to a storage controller failure in the following way:

|Parameter|Behavior|
|---|---|
|Level of failures to tolerate|If the**Level of failures to tolerate** in the VM storage policy is<br>equal to or greater than 1, the virtual machine objects are still<br>accessible from another ESXi host in the cluster. If resources are<br>available, vSAN starts an automatic reprotection.|



VMware by Broadcom 1832


VMware Cloud Foundation 9.0

|Parameter|Behavior|
|---|---|
||If the**Level of failures to tolerate** is set to 0, a virtual machine<br>object is inaccessible if one of the object's components resides on<br>the disk groups that are connected to the storage controller.|
|I/O operations on the isolated hosts|When a vSAN object experiences a failure or a failed component,<br>I/O operations stop between 5-7 seconds until it revaluates if the<br>object is available.<br>If vSAN determines that the object is available, all running<br>operations are resumed.|
|Rebuilding data|vSAN examines whether the ESXi hosts and the capacity devices<br>can satisfy the requirements for space and placement rules for<br>the objects on the failed device or disk group. If such a host<br>with capacity is available, vSAN starts the recovery process<br>immediately because the components are marked as degraded.|



**vSAN Stretched Cluster Site Fails or Loses Network Connection**
A vSAN stretched cluster manages failures that occur due to the loss of a network connection between sites or the
temporary loss of one site.


**vSAN Stretched Cluster Failure Handling**

In most cases, the vSAN stretched cluster continues to operate during a failure and automatically recovers after the failure
is resolved.


**Table 855: How vSAN Stretched Cluster Handles Failures**

|Type of Failure|Behavior|
|---|---|
|Network Connection Lost Between Active Sites|If the network connection fails between the two active sites, the witness<br>host and the preferred site continue to service storage operations, and keep<br>data available. When the network connection returns, objects protected by a<br>policy with a site tolerance attribute are resynchronised|
|Secondary Site Fails or Loses Network Connection|If the secondary site goes offline or becomes isolated from the preferred<br>site and the witness host, the witness host and the preferred site continue to<br>service storage operations, and keep data available, objects protected by a<br>policy with a site tolerance attribute are resynchronised|
|Preferred Site Fails or Loses Network Connection|If the preferred site goes offline or becomes isolated from the secondary site<br>and the witness host, the secondary site continues storage operations if it<br>remains connected to the witness host, objects protected by a policy with a<br>site tolerance attribute are resynchronised|
|Witness Host Fails or Loses Network Connection|If the witness host goes offline or becomes isolated from the preferred<br>site or the secondary site, objects become noncompliant but data remains<br>available. VMs that are currently running are not affected.|



**Troubleshooting vSAN**


Examine the performance and accessibility of virtual machines to diagnose problems in the vSAN cluster.


VMware by Broadcom 1833


VMware Cloud Foundation 9.0


**Verify Drivers, Firmware, Storage I/O Controllers Against the** _**VMware Compatibility Guide**_
Use the vSAN Skyline Health to verify whether your hardware components, drivers, and firmware are compatible with
vSAN.

Using hardware components, drivers, and firmware that are not compatible with vSAN might cause problems in the
operation of the vSAN cluster and the virtual machines running on it.

The hardware compatibility health findings verify your hardware against the _Broadcom Compatibility Guide_ [at https://](https://compatibilityguide.broadcom.com/)
[compatibilityguide.broadcom.com/. For more information about using the vSAN Skyline Health, see Monitoring vSAN](https://compatibilityguide.broadcom.com/)
Skyline Health.

**Examining Performance in vSAN Cluster**
Monitor the performance of virtual machines, ESXi hosts, and the vSAN datastore to identify potential storage problems.

Monitor regularly the following performance indicators to identify faults in vSAN storage, for example, by using the
performance charts in the vSphere Client:

- Datastore. Rate of I/O operations on the aggregated datastore.

- Virtual Machine. I/O operations, memory and CPU usage, network throughput and bandwidth.

You can use the vSAN performance service to access detailed performance charts. For information about using the
performance service, see Monitoring vSAN Performance.


**Network Misconfiguration Status in vSAN Cluster**
After you enable vSAN on a cluster, the datastore is not assembled correctly because of a detected network
misconfiguration.

After you enable vSAN on a cluster, a vSAN Alarm triggers on the Summary tab indicating a network partition.

One or more members of the cluster cannot communicate because of either of the following reasons:

- A host in the cluster does not have a VMkernel adapter for vSAN.

- The ESXi hosts cannot connect each other in the network.

[Troubleshoot network partition errors using the vSAN Skyline Health and the Broadcom knowledge base article 318839.](https://knowledge.broadcom.com/external/article/318839)

**Virtual Machine Appears as Noncompliant, Inaccessible or Orphaned in the vSAN Cluster**
The state of a virtual machine that stores data on a vSAN datastore appears as noncompliant, inaccessible, or orphaned
due to the vSAN cluster failures.

A virtual machine on a vSAN datastore is in one of the following states that indicate a fault in the vSAN cluster.

- The virtual machine or some of its objects are non-compliant to the configured policy. See Examine the Compliance of
a Virtual Machine in vSAN.

- The virtual machine object is inaccessible or orphaned. See Examine the Failure State of a Component.

If an object replica is still available on another host, vSAN forwards the I/O operations of the virtual machine to the replica.

If the object of the virtual machine can no longer satisfy the requirement of the assigned VM storage policy, vSAN
considers it noncompliant. For example, a host might temporarily lose connectivity. See Object States That Indicate
Problems in vSAN .

If vSAN cannot locate a full replica or more than 50 percent of the votes for the object, the virtual machine becomes
inaccessible. If a vSAN detects that the `.vmx` file is not accessible because the VM Home Namespace is maybe
inacessbile, the virtual machine may become orphaned. See Accessibility of Virtual Machines Upon a Failure in vSAN.

If the cluster contains enough resources, vSAN automatically recovers the failed components if the failure is permanent.

If the cluster does not have enough resources to rebuild the failed components, extend the space in the cluster.


VMware by Broadcom 1834


VMware Cloud Foundation 9.0


**Attempt to Create a Virtual Machine on vSAN Fails**
When you try to deploy a virtual machine in a vSAN cluster, the operation fails with an error that the virtual machine files
cannot be created.

The operation for creating a virtual machine fails with an error status: `Cannot complete file creation`
`operation` .

The deployment of a virtual machine on vSAN might fail for several reasons.

- vSAN cannot allocate space for the virtual machine storage policies and virtual machine objects. Such a failure
might occur if the datastore does not have enough usable capacity, for example, if a physical disk is temporarily
disconnected from the host.

- The virtual machine has very large virtual disks and the ESXi hosts in the cluster cannot provide storage for them
based on the placement rules in the VM storage policy
For example, if the **Primary level of failures to tolerate** in the VM storage policy is set to 1, vSAN must store two
replicas of a virtual disk in the cluster, each replica on a different host. The datastore might have this space after
aggregating the free space on all ESXi hosts in the cluster. However, no two ESXi hosts can be available in the cluster,
each providing enough space to store a separate replica of the virtual disk.
vSAN does not move components between ESXi hosts or disks groups to free space for a new replica, even though
the cluster might contain enough space for provisioning the new virtual machine.

Verify the state of the capacity devices in the cluster.
a) In the vSphere Client, navigate to the cluster.
b) On the **Monitor** tab, click **vSAN** and select **Physical Disks** .
c) Examine the capacity and health status of the devices on the ESXi hosts in the cluster.

**vSAN Stretched Cluster Configuration Error When Adding a Host**
Before adding new ESXi hosts to a vSAN stretched cluster, all current ESXi hosts must be connected. If a current host is
disconnected, the configuration of the new host is incomplete.

After you add a host to a vSAN stretched cluster in which some ESXi hosts are disconnected, on the Summary tab for the
cluster the Configuration Status for vSAN appears as `Unicast agent unset on host` .

When a new host joins a stretched cluster, vSAN must update the configuration on all hosts in the cluster. If one or more
hosts are disconnected from the vCenter, the update fails. The new host successfully joins the cluster, but its configuration
is incomplete.

Verify that all ESXi hosts are connected to vCenter, and click the link provided in the Configuration Status message to
update the configuration of the new host.

If you cannot rejoin the disconnected host, remove the disconnected host from the cluster, and click the link provided in
the Configuration Status message to update the configuration of the new host.

**Cannot Add or Remove the Witness Host in vSAN Stretched Cluster**
Before adding or removing the witness host in a vSAN stretched cluster, all current ESXi hosts must be connected. If a
current host is disconnected, you cannot add or remove the witness host.

When you add or remove a witness host in a vSAN stretched cluster in which some ESXi hosts are disconnected, the
operation fails with an error status: `The operation is not allowed in the current state. Not all ESXi`
`hosts in the cluster are connected to Virtual Center` .

When the witness host joins or leaves a stretched cluster, vSAN must update the configuration on all ESXi hosts in the
cluster. If one or more ESXi hosts are disconnected from the vCenter, the witness host cannot be added or removed.

Verify all ESXi hosts are connected to vCenter, and retry the operation. If you cannot rejoin the disconnected host, remove
the disconnected host from the cluster, and then you can add or remove the witness host.


VMware by Broadcom 1835


VMware Cloud Foundation 9.0


**Disk Group Becomes Locked in vSAN Cluster**
In an encrypted vSAN cluster, when communication between a host and the KMS is lost, the disk group can become
locked if the host reboots.

vSAN locks a host's disk groups when the host reboots and it cannot get the KEK from the KMS. The disks behave as if
they are unmounted. Objects on the disks become inaccessible.

You can view a disk group's health status on the Disk Management page in the vSphere Client. An Encryption health
finding warning notifies you that a disk is locked.

ESXi hosts in an encrypted vSAN cluster do not store the KEK on disk. If a host reboots and cannot get the KEK from the
KMS, vSAN locks the host's disk groups.

To exit the locked state, you must restore communication with the KMS and reestablish the trust relationship.

**Replacing Existing Hardware Components in vSAN Cluster**


Under certain conditions, you must replace hardware components, drivers, firmware, and storage I/O controllers in the
vSAN cluster.

In vSAN, you should replace hardware devices when you encounter failures or if you must upgrade your cluster.

vSAN ESA contains a single storage pool of flash devices. Each flash device provides caching and capacity to the cluster.


**Replace a Caching Device on a Host in vSAN Cluster**
You must replace a flash caching device if you detect a failure or when there is a disk group upgrade.

- Verify that the storage controllers on the hosts are configured in passthrough mode and support the hot-plug feature. If
the storage controllers are configured in RAID 0 mode, see the vendor documentation for information about adding and
removing devices.

- If you upgrade the caching device, verify the following requirements:

 - If you upgrade the flash caching device, verify that the cluster contains enough space to migrate the data from the

disk group that is associated with the flash device.

 - Place the host in maintenance mode. See Place a Member of vSAN Cluster in Maintenance Mode.

Removing the cache device removes the entire disk group from the vSAN cluster. When you replace a flash caching
device, the virtual machines on the disk group become inaccessible and the components on the group are marked as
degraded. See A Caching Device Is Not Accessible in a vSAN Cluster.

1. In the vSphere Client, navigate to the cluster.

2. On the **Configure** tab, click **Disk Management** under vSAN.

3. Select the entire disk group that contains the flash caching device that you want to remove. vSAN does not allow you

to remove the cache disk. To remove the cache disk, you must remove the entire disk group.

4.

Click and click **Remove** .

5. In the Remove Disk Group dialog box, select any of the following data migration mode to evacuate the data on the

disks.

  - **Full data migration**   - Transfers all the data available on the host to other ESXi hosts in the cluster.

  - **Ensure accessibility**   - Transfers data available on the host to the other ESXi hosts in the cluster partially. During
the data transfer, all virtual machines on the host remains accessible.

  - **No data migration**   - There is no data transfer from the host. At this time, some objects might become inaccessible.


VMware by Broadcom 1836


VMware Cloud Foundation 9.0


6. Click **Go To Pre-Check** to find the impact on the cluster if the object is removed or placed in maintenance mode.

7. Click **Remove** to remove the disk group.


vSAN removes the flash caching device along with the entire disk group from the cluster.
1. Add a new device to the host.

The host automatically detects the device.
2. If the host is unable to detect the device, perform a device rescan.

For more information on creating a disk group, claiming storage devices, or adding devices to the disk group in the vSAN
Cluster, see Device Management in a vSAN Cluster.

**Replace a Storage Pool Device in vSAN ESA Cluster**
The storage pool represents the amount of capacity provided by the host to the vSAN datastore.

If you upgrade the storage pool device, verify that the cluster contains enough space to migrate the data from the storage
pool device.

Each host's storage devices claimed by vSAN form a storage pool. All storage devices claimed by vSAN contribute to
capacity and performance.

1. In the vSphere Client, navigate to the cluster.

2. On the **Configure** tab, click **Disk Management** under vSAN.

3. Select the storage pool device, and click **Remove Disk** .

4. In the Remove Disk dialog box, select **Full data migration** to transfer all the data available on the host to other ESXi

hosts in the cluster.

5. Click **Go To Pre-Check** to find the impact on the cluster if the object is removed or placed in maintenance mode.

6. Click **Remove** to remove the storage pool device.

1. Add a new device to the host.

The host automatically detects the device.
2. If the host is unable to detect the device, perform a device rescan.
3. Claim a disk using the vSAN cluster > **Configure** - **vSAN** - **Disk Management** .

**Replace a Capacity Device in vSAN OSA Cluster**
You must replace a flash capacity device or a magnetic disk if you detect a failure or when you upgrade it.

- Verify that the storage controllers on the hosts are configured in passthrough mode and support the host-plug feature.
If the storage controllers are configured in RAID 0 mode, see the vendor documentation for information about adding
and removing devices.

- If you upgrade the capacity device, verify that the cluster contains enough space to migrate the data from the capacity
device.

Before you physically remove the device from the host, you must manually delete the device from vSAN. When you
unplug a capacity device without removing it from the vSAN cluster, the components on the disk are marked as absent. If
the capacity device fails, the components on the disk are marked as degraded. When the number of failures of the object
replica with the affected components exceeds the FTT value, the virtual machines on the disk become inaccessible. See
Capacity Device Not Accessible in vSAN Cluster.

**Note:** If your vSAN cluster uses deduplication and compression, you must remove the entire disk group from the cluster
before you replace the device.

You can also watch the video about how to replace a failed capacity device in vSAN.


VMware by Broadcom 1837


VMware Cloud Foundation 9.0


1. In the vSphere Client, navigate to the cluster.

2. On the **Configure** tab, click **Disk Management** under vSAN.

3. Select the flash capacity device or magnetic disk, and click **Remove Disk** .

**Note:**

You cannot remove a capacity device from the cluster with enabled deduplication and compression. You must remove
the entire disk group. If you want to remove a disk group from a vSAN cluster with deduplication and compression
enabled, see Add or Remove Disks with Deduplication and Compression Enabled.

4. In the Remove Disk dialog box, select **Full data migration** to transfer all the data available on the host to other ESXi

hosts in the cluster.

5. Click **Go To Pre-Check** to find the impact on the cluster if the object is removed or placed in maintenance mode.

6. Click **Remove** to remove the capacity device.

You can use ESXCLI commands to remove a device from a host. For more information, see Remove a Device from
a Host in vSAN Cluster by Using an ESXCLI Command. To troubleshoot, identify, and replace a failed disk, see
[Troubleshooting vSAN OSA disk issues and Identifying and replacing a failed disk.](https://knowledge.broadcom.com/external/article/326859)

1. Add a new device to the host.

The host automatically detects the device.
2. If the host is unable to detect the device, perform a device rescan.

**Replace a Storage Controller in vSAN OSA Cluster**
You must replace a storage controller on a host if you detect a failure.

1. Place the host into maintenance mode and power down the host.

2. Replace the failed card.

The replacement storage controller must have a supported firmware level listed in the _Broadcom Compatibility Guide_
[at https://compatibilityguide.broadcom.com/.](https://compatibilityguide.broadcom.com/)

3. Power on the host.

4. Configure the card for passthrough mode. Refer to the vendor documentation for information about configuring the

device.

5. Exit maintenance mode.

**Remove a Device from a Host in vSAN Cluster by Using an ESXCLI Command**
If you detect a failed storage device, a failed disk in a storage pool, or if you upgrade a device, you can manually remove it
from a host by using an ESXCLI command.

Verify that the storage controllers on the hosts are configured in passthrough mode and support the host-plug feature.

If the storage controllers are configured in RAIA 0 mode, see the vendor documentation for information about adding and
removing devices.

If you remove a flash caching device, vSAN deletes the disk group that is associated with the flash device and all its
member devices. If you remove a physical disk from the storage pool, vSAN redistributes the data stored on that disk to
the remaining disks within the pool.


VMware by Broadcom 1838


VMware Cloud Foundation 9.0


1. Open an SSH connection to the ESXi host.

2. Peform one of the following:

  - To identify the device ID of the failed device, run this command and learn the device ID from the output.
```
    esxcli vsan storage list
```

  - To identify the storage pool configuration, run this command.
```
    esxcli vsan storagepool list
```

3. Perform one of the following:

  - To remove the device from vSAN, run this command.
```
    esxcli vsan storage remove -d device_id
```

  - To remove the disk from vSAN storage pool, run this command.
```
    esxcli vsan storagepool remove --disk
```

The following are the commands available for managing vSAN ESA cluster:


**Table 856: vSAN ESA Commands**













|Command|Description|
|---|---|
|`esxcli vsan storagepool add`|Add physical disk for vSAN usage.|
|<br>`esxcli vsan storagepool list`|List vSAN storage pool configuration.|
|<br>`esxcli vsan storagepool mount`|Mount vSAN disk from storage pool.|
|<br>`esxcli vsan storagepool rebuild`|Rebuild vSAN storage pool disks.|
|<br>`esxcli vsan storagepool remove`|Remove physical disk from storage pool. Requires one --disk or --<br>uuid param.|
|`esxcli vsan storagepool unmount`|Unmount vSAN disk from storage pool.|


1. Add a new device to the host.

The host automatically detects the device.
2. If the host is unable to detect the device, perform a device rescan.


VMware by Broadcom 1839


