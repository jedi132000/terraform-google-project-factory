# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

domain           = attribute('domain')
project_id       = attribute('project_id')
region           = attribute('region')
credentials_path = attribute('credentials_path')

ENV['CLOUDSDK_AUTH_CREDENTIAL_FILE_OVERRIDE'] = File.expand_path(
  credentials_path,
  __FILE__)

control 'project-factory-app-engine' do
  title "Project Factory App Engine configuration"

  describe command("gcloud app describe --project #{project_id} --format=json") do
    its('exit_status') { should be 0 }
    its('stderr') { should eq '' }

    let(:metadata) do
      if subject.exit_status == 0
        JSON.parse(subject.stdout, symbolize_names: true)
      else
        {}
      end
    end

    it { expect(metadata).to include(authDomain: domain) }
    it { expect(metadata).to include(featureSettings: Hash.new) }
    it { expect(metadata).to include(id: project_id) }
    it { expect(metadata).to include(name: "apps/#{project_id}") }
    it { expect(metadata).to include(locationId: region) }
    it { expect(metadata).to include(servingStatus: 'SERVING') }
  end
end
