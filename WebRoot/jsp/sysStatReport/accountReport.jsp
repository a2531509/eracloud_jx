<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <base href="<%=basePath%>">
    <title>系统业务凭证查询</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<style>
		.combobox-item{
			cursor:pointer;
		}
		.panel-with-icon:{padding-left:0px;marign-left:0px;}
		.panel-title:{width:13px;padding-left:0px;}
	</style>
	<script type="text/javascript"> 
	//$.fn.datagrid.defaults.loadMsg = '正在处理，请稍待。。。';
		var $dg;
		var $temp;
		var $grid;
		var $querycerttype;
		$(function() {
			$dg = $("#dg");
			createSysCode("cardType",{codeType:"CARD_TYPE",isShowDefaultOption:false});
			createSysCode("accKind",{codeType:"ACC_KIND",isShowDefaultOption:true});
			$("#recType").combobox({
				width:174,
				valueField:'codeValue',
				editable:false,
				value:"1",
			    textField:"codeName",
			    panelHeight:'auto',
			    data:[{codeValue:'1',codeName:"自有网点"}/* ,{codeValue:'2',codeName:"外围接入"} */],
			    onSelect:function(option){
			    	if(option.codeValue=="1"){
			    		$("#branchoo").css("display","table-row");
			    		$("#coOrgoo").css("display","none");
			    		$("#merchantoo").css("display","none");
			    		$grid=$dg.treegrid({
							url : "sysReportQuery/sysReportQueryAction!queryAccountRp.action?rec_Type=1",
							rownumbers:true,
							animate: true,
							collapsible: true,
							fitColumns: true,
							fit:true,
							scrollbarSize:0,
							striped:true,
							border:false,
							singleSelect:true,
							showFooter: true,
							idField: 'id',
							treeField: 'name',
							columns :[[
										{field:'id',title : 'id',hidden:true},
										{field:'name',title:'网点名称',sortable:true,fit:true},
										{field:'per_num',title:'上期结余笔数',sortable:true,width:parseInt($(this).width() * 0.08)},
										{field:'per_amt',title:'上期结余金额',sortable:true,width:parseInt($(this).width() * 0.1)},
										{field:'num',title:'本期内笔数',sortable:true,width:parseInt($(this).width() * 0.08)},
										{field:'amt',title:'本期内金额',sortable:true,width:parseInt($(this).width() * 0.1)},
										{field:'end_num',title:'本期结余笔数',sortable:true,width:parseInt($(this).width() * 0.08)},
										{field:'end_amt',title:'本期结余金额',sortable:true,width:parseInt($(this).width() * 0.1)}
									]],
							  toolbar:'#tb',
							  loadFilter:function(data){
									return data.rows;
							  },
				              onLoadSuccess:function(row,data){
				            	  $("input[type=checkbox]").each(function(){
				        				this.checked = false;
				        		  });
				              }
						});
			    	}else if(option.codeValue=="2"){
			    		$("#branchoo").css("display","none");
			    		$("#merchantoo").css("display","none");
			    		$("#coOrgoo").css("display","table-row");
			    		$grid=$dg.treegrid({
							url : "sysReportQuery/sysReportQueryAction!queryAccountRp.action?rec_Type=2",
							rownumbers:true,
							animate: true,
							collapsible: true,
							fitColumns: true,
							fit:true,
							scrollbarSize:0,
							striped:true,
							border:false,
							singleSelect:true,
							showFooter: true,
							idField: 'id',
							treeField: 'name',
							columns :[[
										{field:'id',title : 'id',hidden:true},
										{field:'name',title:'网点名称',sortable:true,fit:true},
										{field:'per_num',title:'上期结余笔数',sortable:true,width:parseInt($(this).width() * 0.08)},
										{field:'per_amt',title:'上期结余金额',sortable:true,width:parseInt($(this).width() * 0.1)},
										{field:'num',title:'本期内笔数',sortable:true,width:parseInt($(this).width() * 0.08)},
										{field:'amt',title:'本期内金额',sortable:true,width:parseInt($(this).width() * 0.1)},
										{field:'end_num',title:'本期结余笔数',sortable:true,width:parseInt($(this).width() * 0.08)},
										{field:'end_amt',title:'本期结余金额',sortable:true,width:parseInt($(this).width() * 0.1)}
									]],
							  toolbar:'#tb',
							  loadFilter:function(data){
									return data.rows;
							  },
				              onLoadSuccess:function(row,data){
				            	  $("input[type=checkbox]").each(function(){
				        				this.checked = false;
				        		  });
				              }
						});
			    	}else{
			    		$("#branchoo").css("display","none");
			    		$("#coOrgoo").css("display","none");
			    		$("#merchantoo").css("display","table-row");
			    		$grid=$dg.treegrid({
							url : "sysReportQuery/sysReportQueryAction!queryAccountRp.action?rec_Type=0",
							rownumbers:true,
							animate: true,
							collapsible: true,
							fitColumns: true,
							fit:true,
							scrollbarSize:0,
							striped:true,
							border:false,
							singleSelect:true,
							showFooter: true,
							idField: 'id',
							treeField: 'name',
							columns :[[
										{field:'id',title : 'id',hidden:true},
										{field:'name',title:'网点名称',sortable:true,fit:true},
										{field:'per_num',title:'上期结余笔数',sortable:true,width:parseInt($(this).width() * 0.08)},
										{field:'per_amt',title:'上期结余金额',sortable:true,width:parseInt($(this).width() * 0.1)},
										{field:'num',title:'本期内笔数',sortable:true,width:parseInt($(this).width() * 0.08)},
										{field:'amt',title:'本期内金额',sortable:true,width:parseInt($(this).width() * 0.1)},
										{field:'end_num',title:'本期结余笔数',sortable:true,width:parseInt($(this).width() * 0.08)},
										{field:'end_amt',title:'本期结余金额',sortable:true,width:parseInt($(this).width() * 0.1)}
									]],
							  toolbar:'#tb',
							  loadFilter:function(data){
									return data.rows;
							  },
				              onLoadSuccess:function(row,data){
				            	  $("input[type=checkbox]").each(function(){
				        				this.checked = false;
				        		  });
				              }
						});
			    	}
			    }
			});
			$("#dealCode").combobox({ 
			    url:"statistical/statisticalAnalysisAction!getAllDealCodes.action",
			    editable:false,
			    cache: false,
			    panelWidth:300,
			    groupField:"GCODE",
			    width:174,
			   // panelHeight: 'auto',
			    valueField:'CODE_VALUE',   
			    textField:'CODE_NAME',
			    groupFormatter:function(value){
			    	return "<span style=\"color:red;font-weight:600;font-style:italic;\">" + value + "</span>";
			    }
			});
			
			createSysOrg("orgId","branchId","");
			
			$grid=$dg.treegrid({
				url : "sysReportQuery/sysReportQueryAction!queryAccountRp.action?rec_Type=1",
				rownumbers:true,
				animate: true,
				collapsible: true,
				fitColumns: true,
				fit:true,
				scrollbarSize:0,
				striped:true,
				border:false,
				singleSelect:true,
				showFooter: true,
				idField: 'id',
				treeField: 'name',
				columns :[[
							{field:'id',title : 'id',hidden:true},
							{field:'name',title:'网点名称',sortable:true,fit:true},
							{field:'per_num',title:'上期结余笔数',sortable:true,width:parseInt($(this).width() * 0.08)},
							{field:'per_amt',title:'上期结余金额',sortable:true,width:parseInt($(this).width() * 0.1)},
							{field:'num',title:'本期内笔数',sortable:true,width:parseInt($(this).width() * 0.08)},
							{field:'amt',title:'本期内金额',sortable:true,width:parseInt($(this).width() * 0.1)},
							{field:'end_num',title:'本期结余笔数',sortable:true,width:parseInt($(this).width() * 0.08)},
							{field:'end_amt',title:'本期结余金额',sortable:true,width:parseInt($(this).width() * 0.1)}
						]],
				  toolbar:'#tb',
				  loadFilter:function(data){
			  		$dg.treegrid('reloadFooter',data.footer);
					return data.rows;
				  },
	              onLoadSuccess:function(row,data){
	            	  $("input[type=checkbox]").each(function(){
	        				this.checked = false;
	        		  });
	              }
			});
		});
		function query(){
			//判断起始时间和结束时间
			if(dealNull($('#beginTime').val()) ==""||dealNull($('#endTime').val()) ==""){
				$.messager.alert('系统消息','请输入起始时间和结束时间','error');
				return;
			}
			if($("#recType").combobox('getValue')=="1"){
				$dg.treegrid('reload',{
					queryType:'0',//查询类型
					org_Id:$("#orgId").combobox('getValue'),
					brch_Id:$("#branchId").combobox('getValue'), 
					startDate:$('#beginTime').val(),
					endDate:$('#endTime').val(),
				    deal_Code:$('#dealCode').combobox('getValue'),
				    cardType:$('#cardType').combobox('getValue'),
				    accKind:$('#accKind').combobox('getValue')
				});
			}else if($("#recType").combobox('getValue')=="2"){
				$dg.treegrid('reload',{
					queryType:'0',//查询类型
					coOrgId:$("#coOrgId").val(),
					startDate:$('#beginTime').val(),
				    endDate:$('#endTime').val(),
				    deal_Code:$('#dealCode').combobox('getValue'),
				    cardType:$('#cardType').combobox('getValue'),
				    accKind:$('#accKind').combobox('getValue')
				});
			}else if($("#recType").combobox('getValue')=="0"){
				$dg.treegrid('reload',{
					queryType:'0',//查询类型
					merchantId:$("#merchantId").val(),
					startDate:$('#beginTime').val(),
				    endDate:$('#endTime').val(),
				    deal_Code:$('#dealCode').combobox('getValue'),
				    cardType:$('#cardType').combobox('getValue'),
				    accKind:$('#accKind').combobox('getValue')
				});
			}else{
				 $.messager.alert('系统消息','暂时不支持该受理点类型的统计！','error');
			}
			
		}
		function view(){
			 $.messager.alert('系统消息','此功能需要定制开发！','info');
			 return;
		}
		
		function autoCom(){
			if($("#coOrgId").val() == ""){
				$("#coOrgName").val("");
			}
			$("#coOrgId").autocomplete({
				position: {my:"left top",at:"left bottom",of:"#coOrgId"},
			    source: function(request,response){
				    $.post('cooperationAgencyManager/cooperationAgencyAction!initAutoComplete.action',{"co.coOrgId":$("#coOrgId").val(),"queryType":"1"},function(data){
				    	response($.map(data.rows,function(item){return {label:item.label,value:item.text}}));
				    },'json');
			    },
			    select: function(event,ui){
			      	$('#coOrgId').val(ui.item.label);
			        $('#coOrgName').val(ui.item.value);
			        return false;
			    },
		      	focus:function(event,ui){
			        return false;
		      	}
		    }); 
		}
		function autoComByName(){
			if($("#coOrgName").val() == ""){
				$("#coOrgId").val("");
			}
			$("#coOrgName").autocomplete({
			    source:function(request,response){
			        $.post('cooperationAgencyManager/cooperationAgencyAction!initAutoComplete.action',{"co.coOrgName":$("#coOrgName").val(),"queryType":"0"},function(data){
			            response($.map(data.rows,function(item){return {label:item.text,value:item.label}}));
			        },'json');
			    },
			    select: function(event,ui){
			    	$('#coOrgId').val(ui.item.value);
			        $('#coOrgName').val(ui.item.label);
			        return false;
			    },
			    focus: function(event,ui){
			        return false;
			    }
		    }); 
		}
		
		function autoComMer(){
            if($("#merchantId").val() == ""){
                $("#merchantName").val("");
            }
            $("#merchantId").autocomplete({
                position: {my:"left top",at:"left bottom",of:"#merchantId"},
                source: function(request,response){
                    $.post('merchantRegister/merchantRegisterAction!initAutoComplete.action',{"merchant.merchantId":$("#merchantId").val(),"queryType":"1"},function(data){
                        response($.map(data.rows,function(item){return {label:item.label,value:item.text}}));
                    },'json');
                },
                select: function(event,ui){
                      $('#merchantId').val(ui.item.label);
                    $('#merchantName').val(ui.item.value);
                    return false;
                },
                  focus:function(event,ui){
                    return false;
                  }
            }); 
        }
        function autoComByNameMer(){
            if($("#merchantName").val() == ""){
                $("#merchantId").val("");
            }
            $("#merchantName").autocomplete({
                source:function(request,response){
                    $.post('merchantRegister/merchantRegisterAction!initAutoComplete.action',{"merchant.merchantName":$("#merchantName").val(),"queryType":"0"},function(data){
                        response($.map(data.rows,function(item){return {label:item.text,value:item.label}}));
                    },'json');
                },
                select: function(event,ui){
                    $('#merchantId').val(ui.item.value);
                    $('#merchantName').val(ui.item.label);
                    return false;
                },
                focus: function(event,ui){
                    return false;
                }
            }); 
        }
        
        function exportAccountRp(){
        	//判断起始时间和结束时间
			if(dealNull($('#beginTime').val()) ==""||dealNull($('#endTime').val()) ==""){
				$.messager.alert('系统消息','请输入起始时间和结束时间','warning');
				return;
			}
        	
			/* if($("#recType").combobox('getValue')!="1"){
				$.messager.alert('系统消息','','error');
				return;
			} */
        	
			var params = {
				rec_Type:$("#recType").combobox('getValue'),
				org_Id:$("#orgId").combobox('getValue'),
				brch_Id:$("#branchId").combobox('getValue'), 
				startDate:$('#beginTime').val(),
				endDate:$('#endTime').val(),
				deal_Code:$('#dealCode').combobox('getValue'),
				cardType:$('#cardType').combobox('getValue'),
				accKind:$('#accKind').combobox('getValue')
			};
			
			parent.$.messager.progress({
				title:"提示",
				text:"数据处理中, 请稍候..."
			});
			$.post("sysReportQuery/sysReportQueryAction!validExportAccountRp.action", params, function(data){
				parent.$.messager.progress("close");
				if(!data || !data.status || data.status == "1" || !data.expid){
					$.messager.alert("消息提示", data.errMsg, "error");
				} else {
					$('#downloadcsv').attr('src',"sysReportQuery/sysReportQueryAction!exportAccountRp.action?expid=" + data.expid);
				}
			}, "json");
        }
	</script>
  </head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>系统内资金收入和支出</strong></span>进行查询和汇总!</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="border-left:none;border-bottom:none;height:auto;overflow:hidden;">
			<div id="tb" style="padding:2px 0">
				<table cellpadding="0" cellspacing="0" class="tablegrid" style="width:100%">
				    <tr>
				       <td class="tableleft">受理点类型：</td>
				       <td class="tableright" id="org01"><input id="recType" type="text"  class="textinput easyui-validatebox" name="recType"/></td>
					   <td class="tableleft">起始日期：</td>
					   <td class="tableright"><input id="beginTime" type="text" name="beginTime" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
					   <td class="tableleft">结束日期：</td>
					   <td class="tableright"><input id="endTime" type="text"  name="endTime" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
				    </tr>
				    <tr>
				    	<td class="tableleft">交易代码：</td>
					    <td class="tableright"><input  id="dealCode" type="text" class="textinput" name="dealCode"/></td>
					    <td class="tableleft">卡类型：</td>
					    <td class="tableright"><input  id="cardType" type="text" class="textinput" name="cardType"/></td>
					    <td class="tableleft">账户类型：</td>
					    <td class="tableright"><input  id="accKind" type="text" class="textinput" name="accKind"/></td>
				    </tr>
					<tr id="branchoo" style="display:table-row;">
						<td class="tableleft">机构编号：</td>
						<td class="tableright"><input id="orgId" type="text"  class="textinput" name="orgId"/></td>
						<td class="tableleft">所属网点：</td>
						<td class="tableright"><input id="branchId" type="text" class="textinput" name="branchId"/></td>
						<td class="tableright" colspan="2">
							<shiro:hasPermission name="voucherQuery">
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="voucherView">
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-excel'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="exportAccountRp()">导出</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="voucherView">
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-merSettleMon'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="view()">图形汇总</a>
							</shiro:hasPermission>
						</td>

					</tr>
					<tr id="coOrgoo" style="display:none;">
					   <td class="tableleft">合作机构编号：</td>
				       <td class="tableright"><input id="coOrgId" type="text"  class="textinput easyui-validatebox" name="coOrgId" onkeydown="autoCom()" onkeyup="autoCom()"/></td>
				       <td class="tableleft">合作机构名称：</td>
				       <td class="tableright"><input id="coOrgName" type="text"  class="textinput easyui-validatebox" name="coOrgName" onkeydown="autoComByName()" onkeyup="autoComByName()"/></td>
					   <td class="tableright" colspan="2">
							<shiro:hasPermission name="voucherQuery">
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="voucherView">
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-excel'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="view()">导出</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="voucherView">
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-merSettleMon'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="view()">图形汇总</a>
							</shiro:hasPermission>
						</td>
					</tr>
					
					<tr id="merchantoo" style="display:none;">
					   <td class="tableleft">商户编号：</td>
				       <td class="tableright"><input id="merchantId" type="text" class="textinput  easyui-validatebox" name="merchantId"  onkeydown="autoComMer()" onkeyup="autoComMer()" style="width:174px;cursor:pointer;"  /></td>
				       <td class="tableleft">商户名称：</td>
				       <td class="tableright"><input type="text" name="merchantName" id="merchantName" class="textinput" onkeydown="autoComByNameMer()" onkeyup="autoComByNameMer()"/></td>
					   <td class="tableright" colspan="2">
							<shiro:hasPermission name="voucherQuery">
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="voucherView">
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-excel'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="view()">导出</a>
							</shiro:hasPermission>
							<shiro:hasPermission name="voucherView">
								<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-merSettleMon'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="view()">图形汇总</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</div>
	  		<table id="dg" title="财务统计信息"></table>
	  </div>
	<iframe id="downloadcsv" style="display: none"></iframe>
</body>
</html>