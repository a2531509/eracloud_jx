<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $dg;
	var $grid;
	$(function(){
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				query();
			}
		});
		/* createSysCode({
			id:"certType",
			codeType:"CERT_TYPE"
		}); */
		<%-- createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE",
			codeValue:"<%=com.erp.util.Constants.CARD_TYPE_LIST%>",
			isShowDefaultOption:true
		}); --%>
		createSysCode({
			id:"agtCertType",
			codeType:"CERT_TYPE",
			value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"
		});
		createSysCode({
			id:"lss_Flag",
			codeType:"LSS_FLAG",
			isShowDefaultOption:false,
			value:"2"
		});
		$.autoComplete({
			id:"certNo",
			text:"cert_no",
			value:"name",
			table:"base_personal",
			keyColumn:"cert_no"
		});
		$grid = createDataGrid({
			id:"dg",
			url:"cardService/cardServiceAction!findAllLostPerson.action",
			pagination:false,
			fitColumns:true,
			scrollbarSize:0,
			columns:[[
				{field:"CARD_ID",checkbox:true},
				{field:"NAME",title:"姓名",width:parseInt($(this).width() * 0.1),sortable:true},
				{field:"CERTTYPE",title:"证件类型",width:parseInt($(this).width() * 0.1)},
				{field:"CERT_NO",title:"证件号码",width:parseInt($(this).width() * 0.1),sortable:true},
				{field:"CARDTYPE",title:"卡类型",width:parseInt($(this).width() * 0.1)},
				{field:"CARD_NO",title:"卡号",width:parseInt($(this).width() * 0.1),sortable:true},
				{field:"CARDSTATE",title:"卡状态",width:parseInt($(this).width() * 0.1),align:"left"},
				{field:"BUSTYPE",title:"公交类型",width:parseInt($(this).width() * 0.1)}
            ]],
            onLoadSuccess:function(data){
                if(data.status != 0){
              	   $.messager.alert("系统消息",data.errMsg,"error");
                }
                $("input[type=checkbox]").each(function(){
    				this.checked = false;
    			});
                if(data.rows.length > 0){
        	    	$(this).datagrid("selectRow",0);
        	    	$(this).datagrid("checkRow", 0);
        	    }
                $("#form").form("reset");
            },onSelect:function(index,data){
           	    if(data == null)return;
	            $("#accinfo").get(0).src = "jsp/cardService/inneraccinfo.jsp?cardNo=" + data.CARD_NO;
	            if($("#accinfodiv").css("display") != "block"){
		            $("#accinfodiv").show();
	            }
          	}
		});
	});
	function query(){
		if($("#certNo").val().replace(/\s/g,'') == '' && $("#cardNo").val().replace(/\s/g,'') == ''){
			$.messager.alert("系统消息","请输入查询证件号码或是卡号！","error");
			return;
		}
		$("#dg").datagrid('load',{
			queryType:'0',
			//certType:$("#certType").combobox('getValue'), 
			certNo:$('#certNo').val(), 
			//cardType:$("#cardType").combobox('getValue'),
			cardNo:$('#cardNo').val()
		});
	}
	function saveCardLos(){
		var row = $("#dg").datagrid('getSelected');
		if(row){
			var tt = $("#lss_Flag").combobox('getText');
			if(tt == "请选择"){
				$.messager.alert("系统消息","请选择挂失类型","error",function(){
					$("#lss_Flag").combobox("showPanel");
				});
				return;
			}
			$.messager.confirm('系统消息','您确定要' + tt + '卡号为【' + row.CARD_NO + '】的卡片吗？',function(is){
				if(is){
					$.messager.progress({text:'数据处理中，请稍后....'});
					$.ajax({
						url:"cardService/cardServiceAction!tosavegs.action?cardNo="+row.CARD_NO,
						data:$('#form').serialize(),
						success: function(rsp){
							$.messager.progress('close');
							rsp = $.parseJSON(rsp);
							$.messager.alert('系统消息',rsp.message,(rsp.status ? 'info':'error'),function(){
								if(rsp.status){
									showReport('报表信息',rsp.dealNo);
									$("#dg").datagrid('reload');
									$("#form").form("reset");
								}
							});
						},
						error:function(){
							$.messager.progress('close');
							$.messager.alert("系统消息","挂失卡片发生错误：请求失败，请重试！","error");
						}
					});
				}
			});
		}else{
			$.messager.alert("系统消息","请勾选一行将要进行挂失的卡片记录！","error");
		}
	}
	function readIdCard(){
		$.messager.progress({text:'正在获取证件信息，请稍后....'});
		var o = getcertinfo();
		if(dealNull(o["name"]).length == 0){
			$.messager.progress('close');
			return;
		}
		$.messager.progress('close');
		$("#certType").combobox("setValue",'1');
		$("#certNo").val(o["cert_No"]);
		query();
	}
	function readIdCard2(){
		$.messager.progress({text:'正在获取证件信息，请稍后....'});
		var o = getcertinfo();
		if(dealNull(o["name"]).length == 0){
			$.messager.progress('close');
			return;
		}
		$.messager.progress('close');
		$("#agtCertType").combobox("setValue","1");
		$("#agtCertNo").val(o["cert_No"]);
		$("#agtName").val(o["name"]);
	}
	function readSMK2(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var queryCertInfo = getcardinfo();
		if(dealNull(queryCertInfo["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + queryCertInfo["errMsg"],"error");
			$.messager.progress('close');
			return;
		}
		$.messager.progress("close");
		$("#agtCertType").combobox("setValue","1");
		$("#agtCertNo").val(dealNull(queryCertInfo["cert_No"]));
		$("#agtName").val(dealNull(queryCertInfo["name"]));
	}
</script>
<n:initpage title="卡片进行挂失操作！">
	<n:center>
	  	<div id="tb" style="padding:2px 0">
			<table class="tablegrid">
				<tr>
					<!-- <td style="padding-left:5px">证件类型：</td>
					<td style="padding-left:5px"><input id="certType" type="text" class="easyui-combobox  easyui-validatebox" name="certType" value="1" style="width:174px;cursor:pointer;"/></td> -->
					<td class="tableleft">证件号码：</td>
					<td class="tableright"><input name="certNo" class="textinput" id="certNo" type="text" maxlength="18"/></td>
					<!-- <td style="padding-left:5px">卡类型：</td>
					<td style="padding-left:5px"><input id="cardType" type="text" class="easyui-combobox  easyui-validatebox" name="cardType" style="width:174px;"/></td> -->
					<td class="tableleft">卡号：</td>
					<td class="tableright"><input name="cardNo"  class="textinput" id="cardNo" type="text" maxlength="20"/></td>
					<td style="padding-left:5px">
						<shiro:hasPermission name="cardLostSave">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard()">读身份证</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							<a href="javascript:void(0);"  class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-save'" plain="false" onclick="saveCardLos();">确定</a>
						</shiro:hasPermission>
					</td>
				</tr>
			</table>
		</div>
  		<table id="dg" title="用户信息"></table>
	</n:center>
	<div id="test" data-options="region:'south',split:false,border:true" style="height:300px;width:100%;overflow:hidden;border-bottom:none;border-left:none;">
		<form id="form" method="post" class="datagrid-toolbar" style="width:100%;height:100%;">
			<div style="width:100%;display:none;" id="accinfodiv">
	  			<h3 class="subtitle">账户信息</h3>
	  			<iframe name="accinfo" id="accinfo"  width="100%" style="border:none;height:52px;padding:0px;margin:0px;"></iframe>
			</div>
			 <h3 class="subtitle">代理人信息</h3>
			 <table width="100%" class="tablegrid">
				 <tr>
				    <th class="tableleft">挂失类型：</th>
					<td class="tableright"><input name="lss_Flag" id="lss_Flag" value="2" class="textinput" type="text"/></td>
					<th class="tableleft">代理人证件类型：</th>
					<td class="tableright" ><input id="agtCertType" type="text" class="textinput" name="rec.agtCertType" value="1" style="width:174px;"/> </td>
					<th class="tableleft">代理人证件号码：</th>
					<td class="tableright" ><input name="rec.agtCertNo"  class="textinput easyui-validatebox" id="agtCertNo" type="text" validtype="idcard" maxlength="18" /></td>
					<th class="tableleft">代理人姓名：</th>
					<td class="tableright" ><input name="rec.agtName" id="agtName" type="text" class="textinput"  maxlength="30"  /></td>
				</tr>
				<tr>
				 	<th class="tableleft">代理人联系电话：</th>
					<td class="tableright" colspan="1"><input name="rec.agtTelNo" id="agtTelNo" type="text" class="textinput easyui-validatebox"   maxlength="11" validtype="mobile"/></td>
					<td class="tableleft" colspan="6">
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readSMK2()">读市民卡</a>
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard2()">读身份证</a>
					</td>
				</tr>
			</table>
		</form>			
    </div>
</n:initpage>
