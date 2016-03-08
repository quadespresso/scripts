#!/bin/env python

import argparse
import os
import pwd
import shutil


class SetupPermission(object):
    def __init__(self):
        self.eucaDirs = ["etc/eucalyptus",
                         "var/lib/eucalyptus",
                         "var/log/eucalyptus",
                         "var/run/eucalyptus"]

        self.eucaWraps = ["usr/lib/eucalyptus/euca_mountwrap",
                          "usr/lib/eucalyptus/euca_rootwrap"]

        self.copyFiles = {"clc/modules/block-storage-common/udev/55-openiscsi.rules": "/etc/udev/rules.d/55-openiscsi.rules",
                          "clc/modules/block-storage-common/udev/iscsidev.sh": "/etc/udev/scripts/iscsidev.sh",
                          "clc/modules/block-storage/udev/rules.d/12-dm-permissions.rules": "/etc/udev/rules.d/12-dm-permissions.rules",
                          "tools/eucalyptus-nc-libvirt.pkla": "/var/lib/polkit-1/localauthority/10-vendor.d/"}

        self.eucaServices = ["usr/lib/systemd/system/eucalyptus-cc.service",
                             "usr/lib/systemd/system/eucalyptus-cloud.service",
                             "usr/lib/systemd/system/eucalyptus-cloud-upgrade.service",
                             "usr/lib/systemd/system/eucalyptus-cluster.service",
                             "usr/lib/systemd/system/eucalyptus-nc.service",
                             "usr/lib/systemd/system/eucalyptus-node-keygen.service",
                             "usr/lib/systemd/system/eucalyptus-node.service",
                             "usr/lib/systemd/system/eucanetd.service"]

        self.eucalyptusBinLn = ["usr/sbin/eucalyptus-cloud",
                                "usr/sbin/eucalyptus-cluster",
                                "usr/sbin/eucalyptus-node"]

        self.euca_home = None
        self.euca_source = None

    def _walk_recursive(self, paths, fn, *params):
        """
        References:
            https://github.com/eucalyptus/eucalyptus/blob/maint-4.1/clc/eucadmin/eucadmin/utils.py
        """
        symlinks = []
        for path in paths:
            fn(path, *params)
            for dirpath, dirs, files in os.walk(path):
                for d in dirs:
                    fullpath = os.path.join(dirpath, d)
                    if os.path.islink(fullpath):
                        symlinks.append(fullpath)
                    else:
                        fn(fullpath, *params)
                for f in files:
                    fn(os.path.join(dirpath, f), *params)
        return symlinks

    def chown_recursive(self, path, uid, gid):
        path = [path]
        while path:
            path = self._walk_recursive(path, os.chown, uid, gid)

    def chmod_recursive(self, path, mode):
        path = [path]
        while path:
            path = self._walk_recursive(path, os.chmod, mode)

    def copy_files(self, src_files, dest_dir=None):
        """
        Args:
            src_files: list or dict of file sources to be copied.
                       dict src_files consists of {'source file': 'destination file or directory'}
            dest_dir: destination directory, to be used when src_files is a list
        Returns: None
        """
        if type(src_files) is dict:
            for src, dest in src_files.iteritems():
                shutil.copy(os.path.join(self.euca_source, src), dest)
        elif type(src_files) is list and dest_dir:
            for sfile in src_files:
                shutil.copy(os.path.join(self.euca_home, sfile), dest_dir)

    def main(self):
        parser = argparse.ArgumentParser()
        parser.add_argument("-e", "--euca-home", default="/")
        parser.add_argument("-t", "--euca-source", default="tools/")
        args = parser.parse_args()

        if args.euca_source:
            self.euca_source = args.euca_source

        # if os.environ.get('EUCALYPTUS'):
        #     self.euca_home = os.environ.get('EUCALYPTUS')
        # else:
        #     self.euca_home = args.euca_home

        if not os.path.exists("/etc/udev/scripts"):
            os.mkdir("/etc/udev/scripts")

        # Copy Policy Kit file for NC
        self.copy_files(self.copyFiles)

        # copy eucalyptus (systemd) services
        if self.euca_home is not "/":
            self.copy_files(self.eucaServices, "/usr/lib/systemd/system/")

            # for eucaln in self.eucalyptusBinLn:
            #     if os.path.join("/", eucaln):
            #         os.remove(os.path.join("/", eucaln))
            #     os.symlink(os.path.join(self.euca_home, eucaln), os.path.join("/", eucaln))

        directories = map(lambda x: os.path.join(self.euca_home, x), self.eucaDirs)

        wrap_dirs = map(lambda x: os.path.join(self.euca_home, x), self.eucaWraps)
        eucalyptus_uid = pwd.getpwnam('eucalyptus').pw_uid
        eucalyptus_gid = pwd.getpwnam('eucalyptus').pw_gid
        root_uid = pwd.getpwnam('root').pw_gid

        # change chown
        for directory in directories:
            self.chown_recursive(directory, eucalyptus_uid, eucalyptus_gid)

        for ew in wrap_dirs:
            os.chown(ew, root_uid, eucalyptus_gid)
            os.chmod(ew, 04750)

if __name__ == "__main__":
    setup_perms = SetupPermission()
    setup_perms.main()
