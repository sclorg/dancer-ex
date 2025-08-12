import os

import pytest
from pathlib import Path

from container_ci_suite.openshift import OpenShiftAPI

from constants import TAGS, is_test_allowed
test_dir = Path(os.path.abspath(os.path.dirname(__file__)))

VERSION=os.getenv("SINGLE_VERSION")
OS=os.getenv("OS")

TAG = TAGS.get(OS)

class TestDancerAppMySQLExTemplate:

    def setup_method(self):
        self.oc_api = OpenShiftAPI(pod_name_prefix="dancer-example")
        json_raw_file = self.oc_api.get_raw_url_for_json(
            container="s2i-perl-container", dir="imagestreams", filename="perl-rhel.json"
        )
        self.oc_api.import_is(path=json_raw_file, name="perl", skip_check=True)
        json_raw_file = self.oc_api.get_raw_url_for_json(
            container="mysql-container", dir="imagestreams", filename="mysql-rhel.json"
        )
        self.oc_api.import_is(path=json_raw_file, name="mysql", skip_check=True)

    def teardown_method(self):
        self.oc_api.delete_project()

    def test_local_template_inside_cluster(self):
        if not is_test_allowed(OS, VERSION):
            pytest.skip(f"Local templates are not supported for {OS} and {VERSION}")
        expected_output = "Welcome to your Dancer application"
        template_json = "../openshift/templates/dancer-mysql-persistent.json"
        assert self.oc_api.deploy_template(
            template=template_json, name_in_template="dancer-example", expected_output=expected_output,
            openshift_args=[
                "SOURCE_REPOSITORY_REF=master",
                f"PERL_VERSION={VERSION}{TAG}",
                "NAME=dancer-example",
                "MYSQL_VERSION=8.0-el8"
            ]
        )
        assert self.oc_api.is_template_deployed(name_in_template="dancer-example")
        assert self.oc_api.check_response_inside_cluster(
            name_in_template="dancer-example", expected_output=expected_output
        )

    def test_template_inside_cluster(self):
        if not is_test_allowed(OS, VERSION):
            pytest.skip(f"Local templates are not supported for {OS} and {VERSION}")
        expected_output = "Welcome to your Dancer application"
        template_json = self.oc_api.get_raw_url_for_json(
            container="dancer-ex", dir="openshift/templates", filename="dancer-mysql-persistent.json"
        )
        assert self.oc_api.deploy_template(
            template=template_json, name_in_template="dancer-example", expected_output=expected_output,
            openshift_args=[
                "SOURCE_REPOSITORY_REF=master",
                f"PERL_VERSION={VERSION}{TAG}",
                "NAME=dancer-example",
                "MYSQL_VERSION=8.0-el8"
            ]
        )
        assert self.oc_api.is_template_deployed(name_in_template="dancer-example")
        assert self.oc_api.check_response_inside_cluster(
            name_in_template="dancer-example", expected_output=expected_output
        )
