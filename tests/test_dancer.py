import os

import pytest
from pathlib import Path

from container_ci_suite.openshift import OpenShiftAPI

test_dir = Path(os.path.abspath(os.path.dirname(__file__)))

VERSION=os.getenv("SINGLE_VERSION")
if not VERSION:
    VERSION="5.32-ubi8"

class TestDancerAppExTemplate:

    def setup_method(self):
        self.oc_api = OpenShiftAPI(pod_name_prefix="dancer-example")
        json_raw_file = self.oc_api.get_raw_url_for_json(
            container="s2i-perl-container", dir="imagestreams", filename="perl-rhel.json"
        )
        self.oc_api.import_is(path=json_raw_file, name="perl")

    def teardown_method(self):
        self.oc_api.delete_project()

    def test_template_inside_cluster(self):
        expected_output = "Welcome to your Dancer application"
        template_json = self.oc_api.get_raw_url_for_json(
            container="dancer-ex", dir="openshift/templates", filename="dancer.json"
        )
        assert self.oc_api.deploy_template(
            template=template_json, name_in_template="dancer-example", expected_output=expected_output,
            openshift_args=["SOURCE_REPOSITORY_REF=master", f"PERL_VERSION={VERSION}", "NAME=dancer-example"]
        )
        assert self.oc_api.template_deployed(name_in_template="dancer-example")
        assert self.oc_api.check_response_inside_cluster(
            name_in_template="dancer-example", expected_output=expected_output
        )

    def test_template_by_request(self):
        expected_output = "Welcome to your Dancer application"
        template_json = self.oc_api.get_raw_url_for_json(
            container="dancer-ex", dir="openshift/templates", filename="dancer.json"
        )
        assert self.oc_api.deploy_template(
            template=template_json, name_in_template="dancer-example", expected_output=expected_output,
            openshift_args=["SOURCE_REPOSITORY_REF=master", f"PERL_VERSION={VERSION}", "NAME=dancer-example"]
        )
        assert self.oc_api.template_deployed(name_in_template="dancer-example")
        assert self.oc_api.check_response_outside_cluster(
            name_in_template="dancer-example", expected_output=expected_output
        )
