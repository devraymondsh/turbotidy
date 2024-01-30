const builtin = @import("builtin");
const arch_syscall = if (builtin.cpu.arch == .x86_64) @import("x86_64-syscall.zig") else @import("aarch64-syscall.zig");

pub const syscall = arch_syscall.syscall;
pub const SyscallType = arch_syscall.SyscallType;

pub const Error = enum(u16) {
    /// No error occurred.
    /// Same code used for `NSROK`.
    SUCCESS = 0,
    /// Operation not permitted
    PERM = 1,
    /// No such file or directory
    NOENT = 2,
    /// No such process
    SRCH = 3,
    /// Interrupted system call
    INTR = 4,
    /// I/O error
    IO = 5,
    /// No such device or address
    NXIO = 6,
    /// Arg list too long
    @"2BIG" = 7,
    /// Exec format error
    NOEXEC = 8,
    /// Bad file number
    BADF = 9,
    /// No child processes
    CHILD = 10,
    /// Try again
    /// Also means: WOULDBLOCK: operation would block
    AGAIN = 11,
    /// Out of memory
    NOMEM = 12,
    /// Permission denied
    ACCES = 13,
    /// Bad address
    FAULT = 14,
    /// Block device required
    NOTBLK = 15,
    /// Device or resource busy
    BUSY = 16,
    /// File exists
    EXIST = 17,
    /// Cross-device link
    XDEV = 18,
    /// No such device
    NODEV = 19,
    /// Not a directory
    NOTDIR = 20,
    /// Is a directory
    ISDIR = 21,
    /// Invalid argument
    INVAL = 22,
    /// File table overflow
    NFILE = 23,
    /// Too many open files
    MFILE = 24,
    /// Not a typewriter
    NOTTY = 25,
    /// Text file busy
    TXTBSY = 26,
    /// File too large
    FBIG = 27,
    /// No space left on device
    NOSPC = 28,
    /// Illegal seek
    SPIPE = 29,
    /// Read-only file system
    ROFS = 30,
    /// Too many links
    MLINK = 31,
    /// Broken pipe
    PIPE = 32,
    /// Math argument out of domain of func
    DOM = 33,
    /// Math result not representable
    RANGE = 34,
    /// Resource deadlock would occur
    DEADLK = 35,
    /// File name too long
    NAMETOOLONG = 36,
    /// No record locks available
    NOLCK = 37,
    /// Function not implemented
    NOSYS = 38,
    /// Directory not empty
    NOTEMPTY = 39,
    /// Too many symbolic links encountered
    LOOP = 40,
    /// No message of desired type
    NOMSG = 42,
    /// Identifier removed
    IDRM = 43,
    /// Channel number out of range
    CHRNG = 44,
    /// Level 2 not synchronized
    L2NSYNC = 45,
    /// Level 3 halted
    L3HLT = 46,
    /// Level 3 reset
    L3RST = 47,
    /// Link number out of range
    LNRNG = 48,
    /// Protocol driver not attached
    UNATCH = 49,
    /// No CSI structure available
    NOCSI = 50,
    /// Level 2 halted
    L2HLT = 51,
    /// Invalid exchange
    BADE = 52,
    /// Invalid request descriptor
    BADR = 53,
    /// Exchange full
    XFULL = 54,
    /// No anode
    NOANO = 55,
    /// Invalid request code
    BADRQC = 56,
    /// Invalid slot
    BADSLT = 57,
    /// Bad font file format
    BFONT = 59,
    /// Device not a stream
    NOSTR = 60,
    /// No data available
    NODATA = 61,
    /// Timer expired
    TIME = 62,
    /// Out of streams resources
    NOSR = 63,
    /// Machine is not on the network
    NONET = 64,
    /// Package not installed
    NOPKG = 65,
    /// Object is remote
    REMOTE = 66,
    /// Link has been severed
    NOLINK = 67,
    /// Advertise error
    ADV = 68,
    /// Srmount error
    SRMNT = 69,
    /// Communication error on send
    COMM = 70,
    /// Protocol error
    PROTO = 71,
    /// Multihop attempted
    MULTIHOP = 72,
    /// RFS specific error
    DOTDOT = 73,
    /// Not a data message
    BADMSG = 74,
    /// Value too large for defined data type
    OVERFLOW = 75,
    /// Name not unique on network
    NOTUNIQ = 76,
    /// File descriptor in bad state
    BADFD = 77,
    /// Remote address changed
    REMCHG = 78,
    /// Can not access a needed shared library
    LIBACC = 79,
    /// Accessing a corrupted shared library
    LIBBAD = 80,
    /// .lib section in a.out corrupted
    LIBSCN = 81,
    /// Attempting to link in too many shared libraries
    LIBMAX = 82,
    /// Cannot exec a shared library directly
    LIBEXEC = 83,
    /// Illegal byte sequence
    ILSEQ = 84,
    /// Interrupted system call should be restarted
    RESTART = 85,
    /// Streams pipe error
    STRPIPE = 86,
    /// Too many users
    USERS = 87,
    /// Socket operation on non-socket
    NOTSOCK = 88,
    /// Destination address required
    DESTADDRREQ = 89,
    /// Message too long
    MSGSIZE = 90,
    /// Protocol wrong type for socket
    PROTOTYPE = 91,
    /// Protocol not available
    NOPROTOOPT = 92,
    /// Protocol not supported
    PROTONOSUPPORT = 93,
    /// Socket type not supported
    SOCKTNOSUPPORT = 94,
    /// Operation not supported on transport endpoint
    /// This code also means `NOTSUP`.
    OPNOTSUPP = 95,
    /// Protocol family not supported
    PFNOSUPPORT = 96,
    /// Address family not supported by protocol
    AFNOSUPPORT = 97,
    /// Address already in use
    ADDRINUSE = 98,
    /// Cannot assign requested address
    ADDRNOTAVAIL = 99,
    /// Network is down
    NETDOWN = 100,
    /// Network is unreachable
    NETUNREACH = 101,
    /// Network dropped connection because of reset
    NETRESET = 102,
    /// Software caused connection abort
    CONNABORTED = 103,
    /// Connection reset by peer
    CONNRESET = 104,
    /// No buffer space available
    NOBUFS = 105,
    /// Transport endpoint is already connected
    ISCONN = 106,
    /// Transport endpoint is not connected
    NOTCONN = 107,
    /// Cannot send after transport endpoint shutdown
    SHUTDOWN = 108,
    /// Too many references: cannot splice
    TOOMANYREFS = 109,
    /// Connection timed out
    TIMEDOUT = 110,
    /// Connection refused
    CONNREFUSED = 111,
    /// Host is down
    HOSTDOWN = 112,
    /// No route to host
    HOSTUNREACH = 113,
    /// Operation already in progress
    ALREADY = 114,
    /// Operation now in progress
    INPROGRESS = 115,
    /// Stale NFS file handle
    STALE = 116,
    /// Structure needs cleaning
    UCLEAN = 117,
    /// Not a XENIX named type file
    NOTNAM = 118,
    /// No XENIX semaphores available
    NAVAIL = 119,
    /// Is a named type file
    ISNAM = 120,
    /// Remote I/O error
    REMOTEIO = 121,
    /// Quota exceeded
    DQUOT = 122,
    /// No medium found
    NOMEDIUM = 123,
    /// Wrong medium type
    MEDIUMTYPE = 124,
    /// Operation canceled
    CANCELED = 125,
    /// Required key not available
    NOKEY = 126,
    /// Key has expired
    KEYEXPIRED = 127,
    /// Key has been revoked
    KEYREVOKED = 128,
    /// Key was rejected by service
    KEYREJECTED = 129,

    // for robust mutexes

    /// Owner died
    OWNERDEAD = 130,
    /// State not recoverable
    NOTRECOVERABLE = 131,
    /// Operation not possible due to RF-kill
    RFKILL = 132,
    /// Memory page has hardware error
    HWPOISON = 133,

    // nameserver query return codes

    /// DNS server returned answer with no data
    NSRNODATA = 160,
    /// DNS server claims query was misformatted
    NSRFORMERR = 161,
    /// DNS server returned general failure
    NSRSERVFAIL = 162,
    /// Domain name not found
    NSRNOTFOUND = 163,
    /// DNS server does not implement requested operation
    NSRNOTIMP = 164,
    /// DNS server refused query
    NSRREFUSED = 165,
    /// Misformatted DNS query
    NSRBADQUERY = 166,
    /// Misformatted domain name
    NSRBADNAME = 167,
    /// Unsupported address family
    NSRBADFAMILY = 168,
    /// Misformatted DNS reply
    NSRBADRESP = 169,
    /// Could not contact DNS servers
    NSRCONNREFUSED = 170,
    /// Timeout while contacting DNS servers
    NSRTIMEOUT = 171,
    /// End of file
    NSROF = 172,
    /// Error reading file
    NSRFILE = 173,
    /// Out of memory
    NSRNOMEM = 174,
    /// Application terminated lookup
    NSRDESTRUCTION = 175,
    /// Domain name is too long
    NSRQUERYDOMAINTOOLONG = 176,
    /// Domain name is too long
    NSRCNAMELOOP = 177,

    _,
};

pub const MAP = struct {
    pub usingnamespace arch_syscall.MAP;

    /// Share changes
    pub const SHARED = 0x01;
    /// Changes are private
    pub const PRIVATE = 0x02;
    /// share + validate extension flags
    pub const SHARED_VALIDATE = 0x03;
    /// Mask for type of mapping
    pub const TYPE = 0x0f;
    /// Interpret addr exactly
    pub const FIXED = 0x10;
    /// don't use a file
    pub const ANONYMOUS = 0x20;
    // MAP_ 0x0100 - 0x4000 flags are per architecture
    /// populate (prefault) pagetables
    pub const POPULATE = 0x8000;
    /// do not block on IO
    pub const NONBLOCK = 0x10000;
    /// give out an address that is best suited for process/thread stacks
    pub const STACK = 0x20000;
    /// create a huge page mapping
    pub const HUGETLB = 0x40000;
    /// perform synchronous page faults for the mapping
    pub const SYNC = 0x80000;
    /// MAP_FIXED which doesn't unmap underlying mapping
    pub const FIXED_NOREPLACE = 0x100000;
    /// For anonymous mmap, memory could be uninitialized
    pub const UNINITIALIZED = 0x4000000;
};

pub const O = struct {
    pub usingnamespace arch_syscall.O;

    /// read only
    pub const RDONLY = 0o0;
    /// write only
    pub const WRONLY = 0o1;
    /// read and write
    pub const RDWR = 0o2;
};

pub const PROT = struct {
    /// page can not be accessed
    pub const NONE = 0x0;
    /// page can be read
    pub const READ = 0x1;
    /// page can be written
    pub const WRITE = 0x2;
    /// page can be executed
    pub const EXEC = 0x4;
    /// page may be used for atomic ops
    pub const SEM = 0x8;
    /// mprotect flag: extend change to start of growsdown vma
    pub const GROWSDOWN = 0x01000000;
    /// mprotect flag: extend change to end of growsup vma
    pub const GROWSUP = 0x02000000;
};

pub const pid_t = i32;
pub const fd_t = i32;
pub const uid_t = u32;
pub const gid_t = u32;
pub const clock_t = isize;
pub const blksize_t = i32;
pub const nlink_t = u32;
pub const time_t = isize;
pub const mode_t = u32;
pub const off_t = isize;
pub const ino_t = usize;
pub const dev_t = usize;
pub const blkcnt_t = isize;
pub const timespec = extern struct {
    tv_sec: isize,
    tv_nsec: isize,
};

pub const fstat = extern struct {
    /// ID of device containing file
    dev: dev_t,
    /// Inode number
    ino: ino_t,
    /// Protection
    mode: mode_t,
    /// Number of hard links
    nlink: nlink_t,
    /// User ID of owner
    uid: uid_t,
    /// Group ID of owner
    gid: gid_t,
    /// Device ID (if special file)
    rdev: dev_t,
    /// Total size, in bytes
    size: off_t,
    /// Blocksize for file system I/O
    blksize: blksize_t,
    /// Number of 512B blocks allocated
    blocks: blkcnt_t,
    /// Time of last access
    atime: time_t,
    /// Time of last modification
    mtime: time_t,
    /// Time of last status change
    ctime: time_t,
};

pub const stat = extern struct {
    dev: dev_t,
    __dev_padding: u32,
    __ino_truncated: u32,
    mode: mode_t,
    nlink: nlink_t,
    uid: uid_t,
    gid: gid_t,
    rdev: dev_t,
    __rdev_padding: u32,
    size: off_t,
    blksize: blksize_t,
    blocks: blkcnt_t,
    atim: timespec,
    mtim: timespec,
    ctim: timespec,
    ino: ino_t,
};

/// Get the errno from a syscall return value. Zero means no error.
pub fn get_errno(r: usize) Error {
    const signed_r = @as(isize, @bitCast(r));
    const int = if (signed_r > -4096 and signed_r < 0) -signed_r else 0;
    return @as(Error, @enumFromInt(int));
}
