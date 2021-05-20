#include <linux/kobject.h>
#include <linux/string.h>
#include <linux/sysfs.h>
#include <linux/export.h>
#include <linux/init.h>
#include <linux/kexec.h>
#include <linux/profile.h>
#include <linux/stat.h>
#include <linux/sched.h>
#include <linux/capability.h>
#include <linux/compiler.h>
#include <linux/rcupdate.h>	

struct kobject *kernel_kobj;
EXPORT_SYMBOL_GPL(kernel_kobj);

static static ssize_t uevent_seqnum_show(struct kobject *kobj,
				  struct kobj_attribute *attr, char *buf)
{
    return sprintf(buf, "hello");
}
KERNEL_ATTR_RO(fscaps);

static struct attribute * kernel_attrs[] = {
	&fscaps_attr.attr,
	NULL
}


static struct attribute_group kernel_attr_group = {
	.attrs = kernel_attrs,
};

static init __init ksysfs_create(void)
{
    int error;
    
    kernel_kobj = kobject_create_and_add("kernel", NULL);
    if (!kernel_kobj) {
        error = -ENOMEM;
        goto exit;
    }
    error = sysfs_create_group(kernel_kobj, &kernel_attr_group);
    if (error)
        goto kset_exit;
    

    return 0;
    
group_exit:
	sysfs_remove_group(kernel_kobj, &kernel_attr_group);
kset_exit:
	kobject_put(kernel_kobj);
exit:
    return error;
}
