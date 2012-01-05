typedef struct {
 char **strings;
 size_t count;
} git_strarray;

void git_strarray_free(git_strarray *array);
void git_libgit2_version(int *major, int *minor, int *rev);

typedef enum {
 GIT_SUCCESS = 0,
 GIT_ERROR = -1,
 GIT_ENOTOID = -2,
 GIT_ENOTFOUND = -3,
 GIT_ENOMEM = -4,
 GIT_EOSERR = -5,
 GIT_EOBJTYPE = -6,
 GIT_ENOTAREPO = -7,
 GIT_EINVALIDTYPE = -8,
 GIT_EMISSINGOBJDATA = -9,
 GIT_EPACKCORRUPTED = -10,
 GIT_EFLOCKFAIL = -11,
 GIT_EZLIB = -12,
 GIT_EBUSY = -13,
 GIT_EBAREINDEX = -14,
 GIT_EINVALIDREFNAME = -15,
 GIT_EREFCORRUPTED = -16,
 GIT_ETOONESTEDSYMREF = -17,
 GIT_EPACKEDREFSCORRUPTED = -18,
 GIT_EINVALIDPATH = -19,
 GIT_EREVWALKOVER = -20,
 GIT_EINVALIDREFSTATE = -21,
 GIT_ENOTIMPLEMENTED = -22,
 GIT_EEXISTS = -23,
 GIT_EOVERFLOW = -24,
 GIT_ENOTNUM = -25,
 GIT_ESTREAM = -26,
 GIT_EINVALIDARGS = -27,
 GIT_EOBJCORRUPTED = -28,
 GIT_EAMBIGUOUSOIDPREFIX = -29,
 GIT_EPASSTHROUGH = -30,
 GIT_ENOMATCH = -31,
 GIT_ESHORTBUFFER = -32,
} git_error;

const char * git_lasterror(void);
const char * git_strerror(int num);

void git_clearerror(void);

typedef int64_t git_off_t;
typedef int64_t git_time_t;

typedef enum {
 GIT_OBJ_ANY = -2,
 GIT_OBJ_BAD = -1,
 GIT_OBJ__EXT1 = 0,
 GIT_OBJ_COMMIT = 1,
 GIT_OBJ_TREE = 2,
 GIT_OBJ_BLOB = 3,
 GIT_OBJ_TAG = 4,
 GIT_OBJ__EXT2 = 5,
 GIT_OBJ_OFS_DELTA = 6,
 GIT_OBJ_REF_DELTA = 7,
} git_otype;

typedef struct git_odb git_odb;
typedef struct git_odb_backend git_odb_backend;
typedef struct git_odb_object git_odb_object;
typedef struct git_odb_stream git_odb_stream;
typedef struct git_repository git_repository;
typedef struct git_object git_object;
typedef struct git_revwalk git_revwalk;
typedef struct git_tag git_tag;
typedef struct git_blob git_blob;
typedef struct git_commit git_commit;
typedef struct git_tree_entry git_tree_entry;
typedef struct git_tree git_tree;
typedef struct git_treebuilder git_treebuilder;
typedef struct git_index git_index;
typedef struct git_config git_config;
typedef struct git_config_file git_config_file;
typedef struct git_reflog_entry git_reflog_entry;
typedef struct git_reflog git_reflog;

typedef struct git_time {
 git_time_t time;
 int offset;
} git_time;

typedef struct git_signature {
 char *name;
 char *email;
 git_time when;
} git_signature;

typedef struct git_reference git_reference;

typedef enum {
 GIT_REF_INVALID = 0,
 GIT_REF_OID = 1,
 GIT_REF_SYMBOLIC = 2,
 GIT_REF_PACKED = 4,
 GIT_REF_HAS_PEEL = 8,
 GIT_REF_LISTALL = GIT_REF_OID|GIT_REF_SYMBOLIC|GIT_REF_PACKED,
} git_rtype;

typedef struct git_refspec git_refspec;
typedef struct git_remote git_remote;
typedef struct git_transport git_transport;
typedef int (*git_transport_cb)(git_transport **transport);
typedef struct _git_oid git_oid;
struct _git_oid {
 unsigned char id[20];
};
int git_oid_fromstr(git_oid *out, const char *str);
int git_oid_fromstrn(git_oid *out, const char *str, size_t length);

void git_oid_fromraw(git_oid *out, const unsigned char *raw);
void git_oid_fmt(char *str, const git_oid *oid);
void git_oid_pathfmt(char *str, const git_oid *oid);
char * git_oid_allocfmt(const git_oid *oid);
char * git_oid_to_string(char *out, size_t n, const git_oid *oid);

void git_oid_cpy(git_oid *out, const git_oid *src);
int git_oid_cmp(const git_oid *a, const git_oid *b);
int git_oid_ncmp(const git_oid *a, const git_oid *b, unsigned int len);

typedef struct git_oid_shorten git_oid_shorten;
git_oid_shorten *git_oid_shorten_new(size_t min_length);
int git_oid_shorten_add(git_oid_shorten *os, const char *text_oid);

void git_oid_shorten_free(git_oid_shorten *os);

int git_signature_new(git_signature **sig_out, const char *name, const char *email, git_time_t time, int offset);
int git_signature_now(git_signature **sig_out, const char *name, const char *email);
git_signature * git_signature_dup(const git_signature *sig);

void git_signature_free(git_signature *sig);

struct git_odb_stream;

struct git_odb_backend {
 git_odb *odb;

 int (* read)(
   void **, size_t *, git_otype *,
   struct git_odb_backend *,
   const git_oid *);

 int (* read_prefix)(
   git_oid *,
   void **, size_t *, git_otype *,
   struct git_odb_backend *,
   const git_oid *,
   unsigned int);

 int (* read_header)(
   size_t *, git_otype *,
   struct git_odb_backend *,
   const git_oid *);

 int (* write)(
   git_oid *,
   struct git_odb_backend *,
   const void *,
   size_t,
   git_otype);

 int (* writestream)(
   struct git_odb_stream **,
   struct git_odb_backend *,
   size_t,
   git_otype);

 int (* readstream)(
   struct git_odb_stream **,
   struct git_odb_backend *,
   const git_oid *);

 int (* exists)(
   struct git_odb_backend *,
   const git_oid *);

 void (* free)(struct git_odb_backend *);
};

struct git_odb_stream {
 struct git_odb_backend *backend;
 int mode;

 int (*read)(struct git_odb_stream *stream, char *buffer, size_t len);
 int (*write)(struct git_odb_stream *stream, const char *buffer, size_t len);
 int (*finalize_write)(git_oid *oid_p, struct git_odb_stream *stream);
 void (*free)(struct git_odb_stream *stream);
};

typedef enum {
 GIT_STREAM_RDONLY = (1 << 1),
 GIT_STREAM_WRONLY = (1 << 2),
 GIT_STREAM_RW = (GIT_STREAM_RDONLY | GIT_STREAM_WRONLY),
} git_odb_streammode;


typedef struct git_indexer git_indexer;

typedef struct git_remote_head {
               git_oid oid;
               char* name;
} git_remote_head;

typedef struct git_headarray
               unsigned int      len;
               git_remote_head** heads;
} git_headarray;

typedef struct git_indexer_stats {
               unsigned int total;
               unsigned int processed;
} git_indexer_stats;


int git_odb_backend_pack(git_odb_backend **backend_out, const char *objects_dir);
int git_odb_backend_loose(git_odb_backend **backend_out, const char *objects_dir);

int git_odb_new(git_odb **out);
int git_odb_open(git_odb **out, const char *objects_dir);
int git_odb_add_backend(git_odb *odb, git_odb_backend *backend, int priority);
int git_odb_add_alternate(git_odb *odb, git_odb_backend *backend, int priority);

void git_odb_close(git_odb *db);
int git_odb_read(git_odb_object **out, git_odb *db, const git_oid *id);
int git_odb_read_prefix(git_odb_object **out, git_odb *db, const git_oid *short_id, unsigned int len);
int git_odb_read_header(size_t *len_p, git_otype *type_p, git_odb *db, const git_oid *id);
int git_odb_exists(git_odb *db, const git_oid *id);
int git_odb_write(git_oid *oid, git_odb *odb, const void *data, size_t len, git_otype type);
int git_odb_open_wstream(git_odb_stream **stream, git_odb *db, size_t size, git_otype type);
int git_odb_open_rstream(git_odb_stream **stream, git_odb *db, const git_oid *oid);
int git_odb_hash(git_oid *id, const void *data, size_t len, git_otype type);
int git_odb_hashfile(git_oid *out, const char *path, git_otype type);
void git_odb_object_close(git_odb_object *object);
const git_oid * git_odb_object_id(git_odb_object *object);
const void * git_odb_object_data(git_odb_object *object);
size_t git_odb_object_size(git_odb_object *object);

git_otype git_odb_object_type(git_odb_object *object);

int git_repository_open(git_repository **repository, const char *path);
int git_repository_open2(git_repository **repository,
  const char *git_dir,
  const char *git_object_directory,
  const char *git_index_file,
  const char *git_work_tree);
int git_repository_open3(git_repository **repository,
  const char *git_dir,
  git_odb *object_database,
  const char *git_index_file,
  const char *git_work_tree);
int git_repository_discover(char *repository_path, size_t size, const char *start_path, int across_fs, const char *ceiling_dirs);

git_odb * git_repository_database(git_repository *repo);
int git_repository_index(git_index **index, git_repository *repo);
void git_repository_free(git_repository *repo);
int git_repository_init(git_repository **repo_out, const char *path, unsigned is_bare);
int git_repository_head_detached(git_repository *repo);
int git_repository_head_orphan(git_repository *repo);
int git_repository_is_empty(git_repository *repo);

typedef enum {
 GIT_REPO_PATH,
 GIT_REPO_PATH_INDEX,
 GIT_REPO_PATH_ODB,
 GIT_REPO_PATH_WORKDIR
} git_repository_pathid;
const char * git_repository_path(git_repository *repo, git_repository_pathid id);

int git_repository_is_bare(git_repository *repo);
int git_repository_config(git_config **out,
 git_repository *repo,
 const char *user_config_path,
 const char *system_config_path);

int git_revwalk_new(git_revwalk **walker, git_repository *repo);
void git_revwalk_reset(git_revwalk *walker);
int git_revwalk_push(git_revwalk *walk, const git_oid *oid);
int git_revwalk_hide(git_revwalk *walk, const git_oid *oid);
int git_revwalk_next(git_oid *oid, git_revwalk *walk);
void git_revwalk_sorting(git_revwalk *walk, unsigned int sort_mode);

void git_revwalk_free(git_revwalk *walk);
git_repository * git_revwalk_repository(git_revwalk *walk);

int git_reference_lookup(git_reference **reference_out, git_repository *repo, const char *name);
int git_reference_create_symbolic(git_reference **ref_out, git_repository *repo, const char *name, const char *target, int force);
int git_reference_create_oid(git_reference **ref_out, git_repository *repo, const char *name, const git_oid *id, int force);
const git_oid * git_reference_oid(git_reference *ref);
const char * git_reference_target(git_reference *ref);
git_rtype git_reference_type(git_reference *ref);

const char * git_reference_name(git_reference *ref);
int git_reference_resolve(git_reference **resolved_ref, git_reference *ref);

git_repository * git_reference_owner(git_reference *ref);
int git_reference_set_target(git_reference *ref, const char *target);
int git_reference_set_oid(git_reference *ref, const git_oid *id);
int git_reference_rename(git_reference *ref, const char *new_name, int force);
int git_reference_delete(git_reference *ref);
int git_reference_packall(git_repository *repo);
int git_reference_listall(git_strarray *array, git_repository *repo, unsigned int list_flags);
int git_reference_foreach(git_repository *repo, unsigned int list_flags, int (*callback)(const char *, void *), void *payload);

int git_reflog_read(git_reflog **reflog, git_reference *ref);
int git_reflog_write(git_reference *ref, const git_oid *oid_old, const git_signature *committer, const char *msg);

unsigned int git_reflog_entrycount(git_reflog *reflog);
const git_reflog_entry * git_reflog_entry_byindex(git_reflog *reflog, unsigned int idx);

const git_oid * git_reflog_entry_oidold(const git_reflog_entry *entry);

const git_oid * git_reflog_entry_oidnew(const git_reflog_entry *entry);

git_signature * git_reflog_entry_committer(const git_reflog_entry *entry);

char * git_reflog_entry_msg(const git_reflog_entry *entry);

void git_reflog_free(git_reflog *reflog);

int git_object_lookup(
  git_object **object,
  git_repository *repo,
  const git_oid *id,
  git_otype type);
int git_object_lookup_prefix(
  git_object **object_out,
  git_repository *repo,
  const git_oid *id,
  unsigned int len,
  git_otype type);

const git_oid * git_object_id(const git_object *obj);

git_otype git_object_type(const git_object *obj);
git_repository * git_object_owner(const git_object *obj);
void git_object_close(git_object *object);
const char * git_object_type2string(git_otype type);

git_otype git_object_string2type(const char *str);
int git_object_typeisloose(git_otype type);
size_t git_object__size(git_otype type);

static inline int git_blob_lookup(git_blob **blob, git_repository *repo, const git_oid *id)
{
 return git_object_lookup((git_object **)blob, repo, id, GIT_OBJ_BLOB);
}
static inline int git_blob_lookup_prefix(git_blob **blob, git_repository *repo, const git_oid *id, unsigned int len)
{
 return git_object_lookup_prefix((git_object **)blob, repo, id, len, GIT_OBJ_BLOB);
}
static inline void git_blob_close(git_blob *blob)
{
 git_object_close((git_object *) blob);
}
const void * git_blob_rawcontent(git_blob *blob);

int git_blob_rawsize(git_blob *blob);
int git_blob_create_fromfile(git_oid *oid, git_repository *repo, const char *path);
int git_blob_create_frombuffer(git_oid *oid, git_repository *repo, const void *buffer, size_t len);

static inline int git_commit_lookup(git_commit **commit, git_repository *repo, const git_oid *id)
{
 return git_object_lookup((git_object **)commit, repo, id, GIT_OBJ_COMMIT);
}
static inline int git_commit_lookup_prefix(git_commit **commit, git_repository *repo, const git_oid *id, unsigned len)
{
 return git_object_lookup_prefix((git_object **)commit, repo, id, len, GIT_OBJ_COMMIT);
}
static inline void git_commit_close(git_commit *commit)
{
 git_object_close((git_object *) commit);
}

const git_oid * git_commit_id(git_commit *commit);
const char * git_commit_message_encoding(git_commit *commit);

const char * git_commit_message(git_commit *commit);

git_time_t git_commit_time(git_commit *commit);

int git_commit_time_offset(git_commit *commit);

const git_signature * git_commit_committer(git_commit *commit);

const git_signature * git_commit_author(git_commit *commit);
int git_commit_tree(git_tree **tree_out, git_commit *commit);
const git_oid * git_commit_tree_oid(git_commit *commit);

unsigned int git_commit_parentcount(git_commit *commit);
int git_commit_parent(git_commit **parent, git_commit *commit, unsigned int n);
const git_oid * git_commit_parent_oid(git_commit *commit, unsigned int n);
int git_commit_create(
  git_oid *oid,
  git_repository *repo,
  const char *update_ref,
  const git_signature *author,
  const git_signature *committer,
  const char *message_encoding,
  const char *message,
  const git_tree *tree,
  int parent_count,
  const git_commit *parents[]);
int git_commit_create_v(
  git_oid *oid,
  git_repository *repo,
  const char *update_ref,
  const git_signature *author,
  const git_signature *committer,
  const char *message_encoding,
  const char *message,
  const git_tree *tree,
  int parent_count,
  ...);

static inline int git_tag_lookup(git_tag **tag, git_repository *repo, const git_oid *id)
{
 return git_object_lookup((git_object **)tag, repo, id, (git_otype)GIT_OBJ_TAG);
}
static inline int git_tag_lookup_prefix(git_tag **tag, git_repository *repo, const git_oid *id, unsigned int len)
{
 return git_object_lookup_prefix((git_object **)tag, repo, id, len, (git_otype)GIT_OBJ_TAG);
}
static inline void git_tag_close(git_tag *tag)
{
 git_object_close((git_object *) tag);
}
const git_oid * git_tag_id(git_tag *tag);
int git_tag_target(git_object **target, git_tag *tag);

const git_oid * git_tag_target_oid(git_tag *tag);

git_otype git_tag_type(git_tag *tag);

const char * git_tag_name(git_tag *tag);

const git_signature * git_tag_tagger(git_tag *tag);

const char * git_tag_message(git_tag *tag);
int git_tag_create(
  git_oid *oid,
  git_repository *repo,
  const char *tag_name,
  const git_object *target,
  const git_signature *tagger,
  const char *message,
  int force);
int git_tag_create_frombuffer(
  git_oid *oid,
  git_repository *repo,
  const char *buffer,
  int force);
int git_tag_create_lightweight(
  git_oid *oid,
  git_repository *repo,
  const char *tag_name,
  const git_object *target,
  int force);
int git_tag_delete(
  git_repository *repo,
  const char *tag_name);
int git_tag_list(
  git_strarray *tag_names,
  git_repository *repo);
int git_tag_list_match(
  git_strarray *tag_names,
  const char *pattern,
  git_repository *repo);

static inline int git_tree_lookup(git_tree **tree, git_repository *repo, const git_oid *id)
{
 return git_object_lookup((git_object **)tree, repo, id, GIT_OBJ_TREE);
}
static inline int git_tree_lookup_prefix(git_tree **tree, git_repository *repo, const git_oid *id, unsigned int len)
{
 return git_object_lookup_prefix((git_object **)tree, repo, id, len, GIT_OBJ_TREE);
}
static inline void git_tree_close(git_tree *tree)
{
 git_object_close((git_object *) tree);
}
const git_oid * git_tree_id(git_tree *tree);

unsigned int git_tree_entrycount(git_tree *tree);
const git_tree_entry * git_tree_entry_byname(git_tree *tree, const char *filename);
const git_tree_entry * git_tree_entry_byindex(git_tree *tree, unsigned int idx);

unsigned int git_tree_entry_attributes(const git_tree_entry *entry);

const char * git_tree_entry_name(const git_tree_entry *entry);

const git_oid * git_tree_entry_id(const git_tree_entry *entry);

git_otype git_tree_entry_type(const git_tree_entry *entry);
int git_tree_entry_2object(git_object **object_out, git_repository *repo, const git_tree_entry *entry);
int git_tree_create_fromindex(git_oid *oid, git_index *index);
int git_treebuilder_create(git_treebuilder **builder_p, const git_tree *source);

void git_treebuilder_clear(git_treebuilder *bld);
void git_treebuilder_free(git_treebuilder *bld);
const git_tree_entry * git_treebuilder_get(git_treebuilder *bld, const char *filename);
int git_treebuilder_insert(git_tree_entry **entry_out, git_treebuilder *bld, const char *filename, const git_oid *id, unsigned int attributes);

int git_treebuilder_remove(git_treebuilder *bld, const char *filename);
void git_treebuilder_filter(git_treebuilder *bld, int (*filter)(const git_tree_entry *, void *), void *payload);
int git_treebuilder_write(git_oid *oid, git_repository *repo, git_treebuilder *bld);

typedef struct {
 git_time_t seconds;

 unsigned int nanoseconds;
} git_index_time;

typedef struct git_index_entry {
 git_index_time ctime;
 git_index_time mtime;

 unsigned int dev;
 unsigned int ino;
 unsigned int mode;
 unsigned int uid;
 unsigned int gid;
 git_off_t file_size;

 git_oid oid;

 unsigned short flags;
 unsigned short flags_extended;

 char *path;
} git_index_entry;

typedef struct git_index_entry_unmerged {
 unsigned int mode[3];
 git_oid oid[3];
 char *path;
} git_index_entry_unmerged;

typedef struct     git_config_file {
 struct git_config *cfg;
 int (*open)(struct git_config_file *);
 int (*get)(struct git_config_file *, const char *key, const char **value);
 int (*set)(struct git_config_file *, const char *key, const char *value);
 int (*foreach)(struct git_config_file *, int (*fn)(const char *, const char *, void *), void *data);
 void (*free)(struct git_config_file *);
} git_config_file;

int            git_index_open(git_index **index, const char *index_path);
void           git_index_clear(git_index *index);
void           git_index_free(git_index *index);
int            git_index_read(git_index *index);
int            git_index_write(git_index *index);
int            git_index_find(git_index *index, const char *path);
void           git_index_uniq(git_index *index);
int            git_index_add(git_index *index, const char *path, int stage);
int            git_index_add2(git_index *index, const git_index_entry *source_entry);
int            git_index_append(git_index *index, const char *path, int stage);
int            git_index_append2(git_index *index, const git_index_entry *source_entry);
int            git_index_remove(git_index *index, int position);
git_index_entry*
               git_index_get(git_index *index, unsigned int n);
unsigned int   git_index_entrycount(git_index *index);
unsigned int   git_index_entrycount_unmerged(git_index *index);
const git_index_entry_unmerged*
               git_index_get_unmerged_bypath(git_index *index, const char *path);
const git_index_entry_unmerged*
               git_index_get_unmerged_byindex(git_index *index, unsigned int n);
int            git_index_entry_stage(const git_index_entry *entry);
int            git_config_find_global(char *global_config_path);
int            git_config_open_global(git_config **out);
int            git_config_file__ondisk(struct git_config_file **out, const char *path);
int            git_config_new(git_config **out);
int            git_config_add_file(git_config *cfg, git_config_file *file, int priority);
int            git_config_add_file_ondisk(git_config *cfg, const char *path, int priority);
int            git_config_open_ondisk(git_config **cfg, const char *path);
void           git_config_free(git_config *cfg);
int            git_config_get_int(git_config *cfg, const char *name, int *out);
int            git_config_get_long(git_config *cfg, const char *name, long int *out);
int            git_config_get_bool(git_config *cfg, const char *name, int *out);
int            git_config_get_string(git_config *cfg, const char *name, const char **out);
int            git_config_set_int(git_config *cfg, const char *name, int value);
int            git_config_set_long(git_config *cfg, const char *name, long int value);
int            git_config_set_bool(git_config *cfg, const char *name, int value);
int            git_config_set_string(git_config *cfg, const char *name, const char *value);
int            git_config_delete(git_config *cfg, const char *name);
int            git_config_foreach( git_config* cfg, int (*callback)(const char *var_name, const char *value, void *payload), void *payload);
const char*    git_refspec_src(const git_refspec *refspec);
const char*    git_refspec_dst(const git_refspec *refspec);
int            git_refspec_src_match(const git_refspec *refspec, const char *refname);
int            git_refspec_transform(char *out, size_t outlen, const git_refspec *spec, const char *name);
int            git_remote_get(struct git_remote **out, struct git_config *cfg, const char *name);
const char*    git_remote_name(struct git_remote *remote);
const char*    git_remote_url(struct git_remote *remote);
const git_refspec*
               git_remote_fetchspec(struct git_remote *remote);
const git_refspec*
               git_remote_pushspec(struct git_remote *remote);
int            git_remote_connect(struct git_remote *remote, int direction);
int            git_remote_ls(git_remote *remote, git_headarray *refs);
void           git_remote_free(struct git_remote *remote);

int            git_transport_new(git_transport **transport, const char *url);
int            git_transport_connect(git_transport *transport, int direction);
int            git_transport_ls(git_transport *transport, git_headarray *array);
int            git_transport_close(git_transport *transport);
void           git_transport_free(git_transport *transport);
int            git_transport_add(git_transport *transport, const char *prefix);
int            git_status_foreach(git_repository *repo, int (*callback)(const char *, unsigned int, void *), void *payload);
int            git_status_file(unsigned int *status_flags, git_repository *repo, const char *path);

int            git_indexer_new(git_indexer **out, const char *packname);
int            git_indexer_run(git_indexer *idx, git_indexer_stats *stats);
int            git_indexer_write(git_indexer *idx);
const git_oid* git_indexer_hash(git_indexer *idx);
void           git_indexer_free(git_indexer *idx);

