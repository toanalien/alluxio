<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--

    The Alluxio Open Foundation licenses this work under the Apache License, version 2.0
    (the "License"). You may not use this work except in compliance with the License, which is
    available at www.apache.org/licenses/LICENSE-2.0

    This software is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
    either express or implied, as more fully set forth in the License.

    See the NOTICE file distributed with this work for information regarding copyright ownership.

--%>

<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <jsp:include page="header-links.jsp"/>
</head>
<title>Mount System</title>
<body>
<jsp:include page="header-scripts.jsp"/>
<div class="container-fluid" id="app">
    <jsp:include page="/header"/>

    <div class="row-fluid">
        <div class="row-fluid">
            <div class="span12 well">
                <h1 class="text-error">
                    <%= request.getAttribute("fatalError") %>
                </h1>
                <div class="navbar">
                    <div class="navbar-inner">
                        <ul class="nav nav-pills">
                            <button class="btn" data-toggle="modal" data-target="#myModal">New</button>
                        </ul>
                    </div>
                </div>

                <table class="table table-condensed">
                    <thead>
                    <tr>
                        <th>Alluxio Uri</th>
                        <th>Ufs Uri</th>
                        <th>Read only</th>
                        <th>Shared</th>
                        <th>Ufs Type</th>
                        <th>Ufs Capacity Bytes</th>
                        <th>Ufs Used Bytes</th>
                        <th colspan="2">Action</th>
                    </tr>
                    </thead>
                    <tbody>

                    <c:forEach items="${mountTable}" var="mount">
                        <c:choose>
                            <c:when test="${mount.key != '/'}">
                                <tr>
                                    <th><a href="/browse?path=${mount.key}">${mount.key}</a></th>
                                    <th>${mount.value['ufsUri']}</th>
                                    <th>${mount.value['readOnly']}</th>
                                    <th>${mount.value['shared']}</th>
                                    <th>${mount.value['ufsType']}</th>
                                    <th>${mount.value['ufsCapacityBytes']}</th>
                                    <th>${mount.value['ufsUsedBytes']}</th>
                                    <th>
                                        <button class="btn" onclick="unMount('${mount.key}')">Unmount</button>
                                    </th>
                                </tr>
                            </c:when>
                        </c:choose>
                    </c:forEach>

                    </tbody>
                </table>

                <!-- pagination component -->
                <div class="pagination pagination-centered">
                    <ul id="paginationUl">
                    </ul>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="footer.jsp" %>
</div>

<!-- Modal -->
<div id="myModal" class="modal fade" role="dialog">
    <div class="modal-dialog">

        <!-- Modal content-->
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title">Edit Mount Point</h4>
            </div>
            <div class="modal-body">
                <div class="control-group">
                    <label class="control-label" for="ufsType">Ufs Type</label>
                    <div class="controls">
                        <select class="span2" id="ufsType">
                            <option selected="selected">Choose Ufs Type</option>
                            <option value="wasb">Azure Blob Store</option>
                            <option value="ceph">Ceph</option>
                            <option value="glusterfs">GlusterFS</option>
                            <option value="gcs">Google Cloud Storage</option>
                            <option value="hdfs">HDFS</option>
                            <option value="mapr">MapR-FS</option>
                            <option value="minio">Minio</option>
                            <option value="nfs">NFS</option>
                            <option value="obs">OBS</option>
                            <option value="oss">OSS</option>
                            <option value="s3">S3</option>
                            <%--<option value="shdfs">Secure HDFS</option>--%>
                            <option value="swift">Swift</option>
                        </select>
                    </div>
                </div>
                <div id="divForm">
                </div>
            </div>
        </div>
    </div>
</div>


<script type="text/javascript">
    var schema = {
        wasb: {
            alluxio_uri: {
                type: 'string',
                title: 'Allxio URI',
                require: true
            },
            azure_container: {
                type: 'string',
                title: 'Azure Container',
                require: true
            },
            azure_account: {
                type: 'string',
                title: 'Azure Account',
                require: true
            },
            azure_directory: {
                type: 'string',
                title: 'Azure Directory',
                require: true
            },
            azure_access_key: {
                type: 'string',
                title: 'Access Key',
                require: true
            }
        },
        gcs: {
            alluxio_uri: {
                type: 'string',
                title: 'Allxio URI',
                require: true
            },
            gcs_access_key_id: {
                type: 'string',
                title: 'GCS Access Key Id',
                require: true
            },
            gcs_secret_access_key: {
                type: 'string',
                title: 'GCS Secret Access Key',
                require: true
            }
        },
        minio: {
            alluxio_uri: {
                type: 'string',
                title: 'Allxio URI',
                require: true
            },
            endpoint: {
                type: 'string',
                title: 'Endpoint',
                require: true,
                description: 'Hint: http://localhost/minio'
            },
            minio_bucket: {
                type: 'string',
                title: 'Minio Bucket',
                require: true
            },
            minio_directory: {
                type: 'string',
                title: 'Minio Directory',
                require: true
            },
            minio_access_key_id: {
                type: 'string',
                title: 'Minio Access Key Id',
                require: true
            },
            minio_secret_key_id: {
                type: 'string',
                title: 'Minio Secret Key Id',
                require: true
            },
            s3a_inherit_acl: {
                type: 'checkbox',
                title: 'Inherit ACL',
                default: false
            },
            s3_disable_dns_buckets: {
                type: 'checkbox',
                title: 'Disable DNS Buckets',
                default: true
            }
        },
        s3: {
            alluxio_uri: {
                type: 'string',
                title: 'Allxio URI',
                require: true,
                description: 'Hint: /s3'
            },
            aws_access_key_id: {
                type: 'string',
                title: 'AWS Access Key Id',
                require: true,
                description: 'Hint: length = 20'
            },
            aws_secret_key_id: {
                type: 'string',
                title: 'AWS Secret Key Id',
                require: true,
                description: 'Hint: length = 40'
            },
            s3_bucket: {
                type: 'string',
                title: 'S3 Bucket',
                require: true
            },
            s3_directory: {
                type: 'string',
                title: 'S3 Directory',
                require: true,
                default: '/',
                description: 'Default: /'
            }
        },
        ceph: {
            aws_access_key_id: {
                type: 'string',
                title: 'Access Key',
                require: true
            },
            aws_secret_key: {
                type: 'string',
                title: 'Secret Key',
                require: true
            },
            endpoint: {
                type: 'string',
                title: 'Endpoint',
                require: true
            },
            folder: {
                type: 'string',
                title: 'Folder',
                require: true,
                default: '/'
            },
            ceph_inherit_acl: {
                type: 'boolean',
                title: 'Inherit ACL',
                require: true,
                default: false
            },
            s3_disable_dns_buckets: {
                type: 'checkbox',
                title: 'Disable DNS Buckets',
                default: true
            }
        },
        swift: {
            user: {
                type: 'string',
                title: 'User',
                require: true
            },
            tenant: {
                type: 'string',
                title: 'Tenant',
                require: true
            },
            password: {
                type: 'string',
                title: 'Password',
                require: true
            },
            container: {
                type: 'string',
                title: 'Container'
            },
            folder: {
                type: 'string',
                title: 'Folder'
            },
            auth_url: {
                type: 'string',
                title: 'Auth URL'
            },
            use_public_url: {
                type: 'boolean',
                title: 'Use Public URL',
                require: true,
                default: true
            },
            auth_method: {
                type: 'string',
                title: 'Auth Method'
            }
        },
        glusterfs: {
            alluxio_uri: {
                type: 'string',
                title: 'Allxio URI',
                require: true,
                description: 'Hint: /glusterfs'
            },
            alluxio_underfs_address: {
                type: 'string',
                title: 'Address',
                require: true,
                description: 'Hint: /mnt/gluster'
            }
        },
        hdfs: {
            alluxio_uri: {
                type: 'string',
                title: 'Allxio URI',
                require: true,
                description: 'Hint: /hdfs'
            },
            alluxio_underfs_address: {
                type: 'string',
                title: 'Address',
                require: true,
                description: 'Hint: hdfs://localhost:8020/'
            }
        },
        mapr: {
            alluxio_uri: {
                type: 'string',
                title: 'Allxio URI',
                require: true,
                description: 'Hint: /mapr'
            },
            alluxio_underfs_address: {
                type: 'string',
                title: 'Address',
                require: true,
                description: 'Hint: maprfs:///path/'
            }
        },
        "oss": {
            alluxio_uri: {
                type: 'string',
                title: 'Allxio URI',
                require: true,
                description: 'Hint: /oss'
            },
            oss_access_key_id: {
                type: 'string',
                title: 'Access Key',
                require: true
            },
            oss_access_key_secret: {
                type: 'string',
                title: 'Secret Key',
                require: true
            },
            oss_endpoint: {
                type: 'string',
                title: 'Endpoint',
                require: true
            },
            oss_directory: {
                type: 'string',
                title: 'Directory',
                require: true,
                default: '/'
            }
        },
        nfs: {
            alluxio_uri: {
                type: 'string',
                title: 'Allxio URI',
                require: true,
                description: 'Hint: /nfs'
            },
            alluxio_underfs_address: {
                type: 'string',
                title: 'Address',
                require: true,
                description: 'Hint: localhost'
            }
        },
        "obs": {
            alluxio_uri: {
                type: 'string',
                title: 'Allxio URI',
                require: true,
                description: 'Hint: /obs'
            },
            obs_access_key_id: {
                type: 'string',
                title: 'Access Key',
                require: true
            },
            obs_access_key_secret: {
                type: 'string',
                title: 'Secret Key',
                require: true
            },
            obs_endpoint: {
                type: 'string',
                title: 'Endpoint',
                require: true
            },
            obs_directory: {
                type: 'string',
                title: 'Directory',
                require: true,
                default: '/'
            }
        },
    };
    var commonOption = {
        read_only: {
            type: 'checkbox',
            title: 'Read Only',
            require: true,
            default: true
        }
    };

    $('#ufsType').on('change', function () {

        var val = this.value;
        $('form').remove();
        $("#divForm").append("<form method='POST' action='/mount'></form>");

        $('form').jsonForm({
            schema: $.extend({}, schema[val], commonOption),
            onSubmit: function (errors, values) {
                values['ufsType'] = $('#ufsType').val();
                console.log(values);
                $.ajax({
                    url: "/mount",
                    data: values,
                    type: "POST",
                    success: function () {
                        location.reload();
                    },
                    error: function (xhr) {
                        alert(JSON.parse(xhr.responseText)['message']);
                    }
                })
            }
        });
    });

    function unMount(id) {
        var r = confirm("Are you sure do this action?");
        if (r === true)
            $.ajax({
                url: "/mount?path=" + id,
                type: "DELETE",
                success: function () {
                    location.reload();
                },
                error: function (xhr, status, error) {
                    alert(error.message);
                }
            })
    }
</script>

</body>
</html>
