#!/bin/sh
###########################################
#
#  Copyright (c) 2017 xrdavies@gmail.com
#  All rights reserved.
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the copyright holders nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS
#  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
#  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
#  IN NO EVENT SHALL THE COPYRIGHT HOLDERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
#  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;LOSS OF USE, DATA,
#  OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
#  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
#  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
#  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
###########################################

#
#  you can create alias command in your profile or just call this gitsync.sh directly
#  in your project root directory.
#

root_dir=`pwd`
echo "project root ${root_dir}"

git fetch upstream
git fetch origin
origin_branches=`git branch -a | grep "remotes/origin" | grep -v "remotes/origin/HEAD" | sed "s/.*remotes\/origin\///g"`
upstream_branches=`git branch -a | grep "remotes/upstream" | grep -v "remotes/upstream/HEAD" | sed "s/.*remotes\/upstream\///g"`
local_branches=`git branch -a | grep -v "remotes/upstream" | grep -v "remotes/origin"`

is_in_list() {
	list=$2
	item=$1
	for i in ${list}; do
		if [[ "${item}" == "${i}" ]]; then
			# echo "found one" ${item} ${i}
			return 1
		fi
	done
	return 0
}

for branch in ${upstream_branches}; do
	
	is_in_list "${branch}" "${origin_branches}"
	ret=$?
	if [[ ${ret} -eq 1 ]]; then
		is_in_list "${branch}" "${local_branches}"
		ret=$?
		if [[ ${ret} -eq 1 ]]; then
			echo "${branch} exists in remotes/origin and in local, merge it and push to origin"
			git checkout ${branch}
			git merge upstream/${branch}
			git push origin ${branch}
		else
			echo "${branch} exists in remotes/origin but not in local, merge it and push to origin"
			git checkout -b ${branch} origin/${branch}
			git merge upstream/${branch}
			git push origin ${branch}
		fi
	else
		is_in_list "${branch}" "${local_branches}"
		ret=$?
		if [[ ${ret} -eq 1 ]]; then
			echo "${branch} not exists in remotes/origin but in local, checkout, merge and push to origin"
			git checkout ${branch}
			git merge upstream/${branch}
			git push origin ${branch}
		else
			echo "${branch} not exists in remotes/origin or in local, checkout from remotes/upstream and push to origin"
			git checkout -b ${branch} upstream/${branch}
			git push origin ${branch}
		fi
	fi
done
