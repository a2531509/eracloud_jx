<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp"%>
<script type='text/javascript' src='dwr/interface/imgDeal.js'></script>
<script type="text/javascript">
	var row;
	var $grid;
  	$(function() {
  		$(document).keypress(function(event){
			if(event.keyCode == 13){
				query();
			}
		});
  		
		$.autoComplete({
			id:"certNo",
			text:"cert_no",
			value:"name",
			table:"base_personal",
			keyColumn:"cert_no"
		},"name");
		$.autoComplete({
			id:"name",
			text:"name",
			value:"cert_no",
			table:"base_personal",
			keyColumn:"name",
			minLength:"1"
		},"certNo");
		$grid = createDataGrid({
			id:"dg",
			url:"basicPhotoAction/basicPhotoAction!findPersonAllList.action",
			pagination:true,
			rownumbers:true,
			border:false,
			fit:true,
			singleSelect:true,
			fitColumns:true,
			scrollbarSize:0,
			striped:true,
			columns:[[
			    {field:"CUSTOMER_ID",title:"客户编号",width:parseInt($(this).width()*0.1),sortable:true},
	            {field:"CERTTYPE",title:"证件类型",width:parseInt($(this).width()*0.1),sortable:true,align: "left"},
	           	{field:"CERT_NO",title:"证件号码",width:parseInt($(this).width()*0.2),sortable:true},
	            {field:"NAME",title:"姓名",width:parseInt($(this).width()*0.1),sortable:true},
	            {field:"BIRTHDAY",title:"出生日期",width:parseInt($(this).width()*0.1),sortable:true},
	            {field:"NATIONSTR",title:"民族",width:parseInt($(this).width()*0.1),sortable:true,align:"left"},
	            {field:"ISPHOTO",title:"照片是否存在",width:parseInt($(this).width()*0.1),sortable:true,formatter:function(value,row){
		          	if("1" <= row.ISPHOTO){
		            	return '<span style="color:red">' + '是' + '</span>';
		            }else{
		            	return '<span style="color:green">' + '否' + '</span>';
		            }
	            }},
	            {field:"RESIDE_ADDR",title:"居住地址",sortable:true}
	        ]],
	        onLoadSuccess:function(data){
				if(dealNull(data["status"]) != 0){
					$.messager.alert('系统消息',data.errMsg,'warning');
				}else{
					$grid.datagrid("selectRow",0);
				}
			},
	        onClickRow: function(index,field,value){
	        	row = $grid.datagrid("getSelected");
		       	var f = $("#form");
				f.form("load",row);
		    }
		});
	});
 	function query(){
 		if($("#certNo").val() == "" && $("#name").val() == "") {
 			$.messager.alert("系统消息","请输入查询条件！<div style=\"color:red\">提示：证件号码或姓名</div>","warning");
 			return;
 		}
		$grid.datagrid("load",{
			queryType:"0",
			name:$("#name").val(), 
			certNo:$("#certNo").val()
		});
    }
 	function readIdCard(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var o = getcertinfo();
		if(dealNull(o["name"]).length == 0){
			$.messager.progress("close");
			return;
		}
		$.messager.progress("close");
		$("#certNo").val(o["cert_No"]);
		$("#name").val(o["name"]);
		query();
	}
 	function photoSignUpload(){
 		var row = $grid.datagrid("getSelected");
 		if(row){
 			if(row.ISPHOTO >= "1"){
 				$.messager.confirm("确认对话框", "该客户照片信息已存在，您确定要覆盖照片？",function(r){
 					if(r){
 						$.modalDialog({
 			  				title:"照片导入",
 			  				width:800,
 			  				height:350,
 			  				resizable:false,
 			  				href:"jsp/photoImport/photoSignImportView.jsp",
 			  				onLoad:function(){
 			  					if(row){
 			  						var f = $.modalDialog.handler.find("#form");
 			  						f.form("load", {"personPhotoId":row.CUSTOMER_ID});
	  			  					imgDeal.getImgMessage(row.CUSTOMER_ID,function(data){
	  			  						if(data.isOK == "0"){
					            	  		dwr.util.setValue("preview",data.imageMsg);
	  			  						}else{
	  			  							jAlert(data.errMsg);
	  			  						}
				            	  	});
 			  					}
 			  				},
  			  				buttons:[
	  			  				{
									text:"保存",
									iconCls:"icon-ok",
									handler:function() {
										fileUpload();
									}
								},{
									text:"取消",
									iconCls:"icon-cancel",
									handler:function() {
										$.modalDialog.handler.dialog("destroy");
									    $.modalDialog.handler = undefined;
									}
								}
				   			]
 			  			});
 					}
 				});
 			}else{
 				$.modalDialog({
	  				title:"照片选择导入",
	  				width:800,
	  				height:350,
	  				resizable:false,
	  				href:"jsp/photoImport/photoSignImportView.jsp",
	  				onLoad:function(){
	  					if(row){
	  						var f = $.modalDialog.handler.find("#form");
	  						f.form("load", {"personPhotoId":row.CUSTOMER_ID});
	  					}
	  				},
 			  		buttons:[
	 			  		{
							text:"保存",
							iconCls:"icon-ok",
							handler:function() {
								fileUpload();
							}
						},
						{
							text:"取消",
							iconCls:"icon-cancel",
							handler:function() {
								$.modalDialog.handler.dialog("destroy");
							    $.modalDialog.handler = undefined;
							}
						}
			   		]
 				});
 			};
 		}else{
 			jAlert("请选择一行记录信息！","warning");
 		}
 	}
 	function readCertUpload(){
 		var photoinfo = getcertinfo();
 		if(CardCtl.Status == 0){
 			return;
 		}
 		$.modalDialog({
			title:"读身份证导入",
			width:800,
			height:350,
			resizable:false,
			href:"jsp/photoImport/readIDCardphoto.jsp",
			onLoad:function(){
					var f = $.modalDialog.handler.find("#form");
					f.form("load", {"certNo":photoinfo["cert_No"],"personPhotoContent":photoinfo["photo"]});
					imgDeal.getImgMessageByCard(photoinfo["photo"],function(data){
            	  		dwr.util.setValue("preview",data.imageMsg);
            	  	});
			},
  			buttons:[{
				text:"保存",
				iconCls:"icon-ok",
				handler:function() {
					fileUpload();
				}
			},{
				text:"取消",
				iconCls:"icon-cancel",
				handler:function() {
					$.modalDialog.handler.dialog("destroy");
				    $.modalDialog.handler = undefined;
				}
			}
   		]
		});
 	}
 	function photoZipUpload(uploadType){
		$.modalDialog({
			title: uploadType == "0" ? "按身份证号批量导入" : "按客户编号批量导入",
			width:800,
			height:350,
			resizable:false,
			href:"jsp/photoImport/photoZipUploadView.jsp",
			buttons:[{
				text:"保存",
				iconCls:"icon-ok",
				handler:function() {
					fileUpload(uploadType);
				}
			},{
				text:"取消",
				iconCls:"icon-cancel",
				handler:function() {
					$.modalDialog.handler.dialog("destroy");
				    $.modalDialog.handler = undefined;
				}
			}]
		});
 	}
	function photoProcessUpload() {
		var rows = $grid.datagrid("getChecked");
		if (rows.length == 1) {
			$.modalDialog({
				title: "照片处理导入",
				width: 850,
				height: 550,
				resizable: false,
				href: "jsp/photoImport/photoProcessUploadView.jsp",
				onLoad: function() {
					var f = $.modalDialog.handler.find("#form");
					f.form("load", {
						"customerId": rows[0].CUSTOMER_ID
					});
				},
				buttons:[
				    {
						text: "保存",
						iconCls: "icon-ok",
						handler: function() {
							photoProcessDataUpload();
						}
					}, 
					{
						text: "取消",
						iconCls: "icon-cancel",
						handler: function() {
							$.modalDialog.handler.dialog("destroy");
							$.modalDialog.handler = undefined;
						}
					}
				]
			});
		} else {
			$.messager.alert("系统消息", "请选择一条记录！", "error");
		}
	}
</script>
<n:initpage title="用户进行照片的导入操作！<span style='color:red'>注意：</span>当客户照片已经存在时，重复进行导入将会覆盖客户原始照片！">
	<n:center>
		<div id="tb" style="padding:2px 0">
			<table class="tablegrid">
				<tr>
					<td class="tableleft" style="width: 8%">证件号码：</td>
					<td class="tableright" style="width: 17%"><input id="certNo" type="text" class="textinput easyui-validatebox" name="certNo" validtype="idcard" maxlength="18"/></td>
					<td class="tableleft" style="width: 8%">姓名：</td>
					<td class="tableright" style="width: 17%"><input id="name" type="text" class="textinput easyui-validatebox" name="name" maxlength="30"/></td>
					<td style="padding-left:3px; width: 50%">
						<a data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard()">读身份证</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false" onclick="query();">查询</a>
						<shiro:hasPermission name="photoSignUpload">
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-import" plain="false" onclick="photoSignUpload();">照片导入</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-import" plain="false" onclick="photoProcessUpload();">照片处理导入</a>
						</shiro:hasPermission>
						<shiro:hasPermission name="photoZipUpload">
							<a href="javascript:void(0);" class="easyui-menubutton" iconCls="icon-import"data-options="menu:'#importMenu'"  plain="false" onclick="javascript:void(0);">批量上传</a>
						</shiro:hasPermission>
					</td>
				</tr>
			</table>
		</div>
		<div id="importMenu" style="width:50px;display: none;">
			<div data-options="iconCls: 'icon-import'" onclick="photoZipUpload('0');">按身份证号上传</div>
			<div data-options="iconCls: 'icon-import'" onclick="photoZipUpload('1');">按客户编号上传</div>
		</div>
  		<table id="dg" title="用户信息"></table>
  	</n:center>
</n:initpage>