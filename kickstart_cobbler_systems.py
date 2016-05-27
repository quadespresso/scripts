#!/usr/bin/python -u
import argparse
import getpass
import xmlrpclib
import logging

import time


class KickStartCobblerSystems(object):
    def __init__(self, cobbler_url, cobbler_user, cobbler_password,
                 cobbler_profile=None, batch=20, delay=600):
        logging.basicConfig(format='%(asctime)s %(message)s', level=logging.DEBUG)

        self.cobbler_profile = cobbler_profile
        self.batch = batch
        self.delay = delay
        self.cobbler = xmlrpclib.Server(cobbler_url)
        try:
            self.cobbler_token = self.cobbler.login(cobbler_user, cobbler_password)
        except:
            raise Exception("Login failed.")

    def get_systems_by_dhcp_tag(self, dhcp_tag):
        scale_systems = self.cobbler.find_system({'dhcp_tag': dhcp_tag})
        if not scale_systems:
            raise Exception("No Systems found.")
        logging.info("Found " + str(len(scale_systems)) + " systems.")
        return scale_systems

    def get_systems(self, **kwargs):
        scale_systems = self.cobbler.find_system(kwargs)
        if not scale_systems:
            raise Exception("No Systems found.")
        logging.info("Found " + str(len(scale_systems)) + " systems.")
        return scale_systems

    def update_cobbler_systems(self, cobbler_systems, cobbler_profile=None, netboot_enabled=True):
        if type(cobbler_systems) is not list:
            raise TypeError("'cobbler_systems' must be a list.")
        if not cobbler_profile:
            cobbler_profile = self.cobbler_profile

        logging.info("Updating cobbler systems with: " + str({'cobbler_profile': cobbler_profile,
                                                              'netboot_enabled': netboot_enabled}))

        for cobbler_system in cobbler_systems:
            system_handle = self.cobbler.get_system_handle(cobbler_system, self.cobbler_token)
            if cobbler_profile:
                logging.info("Updating cobbler system '" + cobbler_system +
                             "' with cobbler profile '" + cobbler_profile + "'.")
                self.cobbler.modify_system(system_handle, "profile", cobbler_profile, self.cobbler_token)
            if netboot_enabled:
                self.cobbler.modify_system(system_handle, "netboot-enabled", 1, self.cobbler_token)
            self.cobbler.save_system(system_handle, self.cobbler_token)

    def reboot_system(self, cobbler_system):
        logging.info("Rebooting system '" + cobbler_system + "'.")
        reboot_args = {"power": "reboot", "systems": [cobbler_system]}
        self.cobbler.background_power_system(reboot_args, self.cobbler_token)

    def reboot_cobbler_systems(self, cobbler_systems, batch=None, delay=None):
        if not batch:
            batch = self.batch
        if not delay:
            delay = self.delay
        logging.info("Rebooting hosts in batch of " + str(batch) + " with " + str(delay) + " seconds delay.")
        for i in range(len(cobbler_systems) / batch + 1):
            batch_systems = cobbler_systems[batch * i:batch * (i + 1)]
            for host in batch_systems:
                print host
            reboot_args = {"power": "reboot", "systems": batch_systems}
            self.cobbler.background_power_system(reboot_args, self.cobbler_token)
            logging.info("Sleeping for " + str(delay) + " seconds.")
            time.sleep(delay)

    def reset_systems(self):
        # TODO make changes so that parser can accept multiple tags
        cobbler_systems = self.get_systems(dhcp_tag='qa2')
        self.update_cobbler_systems(cobbler_systems)
        self.reboot_cobbler_systems(cobbler_systems)


def main():
    parser = argparse.ArgumentParser()
    required_args = parser.add_argument_group('required arguments')
    required_args.add_argument("-u", "--user", type=str, help="Cobbler Username", required=True)
    parser.add_argument("--url", type=str, help="Cobbler Url", required=True)

    parser.add_argument("--profile", type=str, help="Cobbler Profile Name")
    parser.add_argument("-p", "--password", help='Enter your password')
    parser.add_argument("--batch", type=int, help="Number of machines to reboot at a time")
    parser.add_argument("--delay", type=int, help="Delay between reboots")
    args = parser.parse_args()

    if args.password is None:
        args.password = getpass.getpass("Enter password: ")

    reset_scale = KickStartCobblerSystems(cobbler_url=args.url,
                                          cobbler_user=args.user,
                                          cobbler_password=args.password,
                                          cobbler_profile=args.profile,
                                          batch=args.batch,
                                          delay=args.delay)
    reset_scale.reset_systems()

if __name__ == "__main__":
    main()
